/// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.21;

import { IERC20 } from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import { IDstSwapper } from "../interfaces/IDstSwapper.sol";
import { ISuperRegistry } from "../interfaces/ISuperRegistry.sol";
import { IBaseStateRegistry } from "../interfaces/IBaseStateRegistry.sol";
import { IBridgeValidator } from "../interfaces/IBridgeValidator.sol";
import { ISuperRBAC } from "../interfaces/ISuperRBAC.sol";
import { IERC4626Form } from "../forms/interfaces/IERC4626Form.sol";
import { Error } from "../utils/Error.sol";
import { DataLib } from "../libraries/DataLib.sol";
import "../types/DataTypes.sol";

/// @title DstSwapper
/// @author Zeropoint Labs.
/// @dev handles all destination chain swaps.
contract DstSwapper is IDstSwapper, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /*///////////////////////////////////////////////////////////////
                    Constants
    //////////////////////////////////////////////////////////////*/
    ISuperRegistry public immutable superRegistry;
    uint64 public immutable CHAIN_ID;
    address constant NATIVE = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /*///////////////////////////////////////////////////////////////
                    State Variables
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 payloadId => mapping(uint256 superformId => FailedSwap)) internal failedSwap;
    mapping(uint256 payloadId => mapping(uint256 index => uint256 amount)) public swappedAmount;

    modifier onlySwapper() {
        if (
            !ISuperRBAC(superRegistry.getAddress(keccak256("SUPER_RBAC"))).hasRole(
                keccak256("DST_SWAPPER_ROLE"), msg.sender
            )
        ) {
            revert Error.NOT_SWAPPER();
        }
        _;
    }

    modifier onlyEmergencyAdmin() {
        if (!ISuperRBAC(superRegistry.getAddress(keccak256("SUPER_RBAC"))).hasEmergencyAdminRole(msg.sender)) {
            revert Error.NOT_EMERGENCY_ADMIN();
        }
        _;
    }

    /// @param superRegistry_ superform registry contract
    constructor(address superRegistry_) {
        if (block.chainid > type(uint64).max) {
            revert Error.BLOCK_CHAIN_ID_OUT_OF_BOUNDS();
        }

        CHAIN_ID = uint64(block.chainid);
        superRegistry = ISuperRegistry(superRegistry_);
    }

    /*///////////////////////////////////////////////////////////////
                            External Functions
    //////////////////////////////////////////////////////////////*/
    /// @notice receive enables processing native token transfers into the smart contract.
    /// @dev liquidity bridge fails without a native receive function.
    receive() external payable { }

    struct ProcessTxVars {
        address finalDst;
        address to;
        address underlying;
        uint256 expAmount;
        uint256 maxSlippage;
    }

    /// @inheritdoc IDstSwapper
    function processTx(
        uint256 payloadId_,
        uint256 index_,
        uint8 bridgeId_,
        bytes calldata txData_
    )
        public
        override
        onlySwapper
        nonReentrant
    {
        if (swappedAmount[payloadId_][index_] != 0) {
            revert Error.DST_SWAP_ALREADY_PROCESSED();
        }

        ProcessTxVars memory v;
        uint64 chainId = CHAIN_ID;

        IBridgeValidator validator = IBridgeValidator(superRegistry.getBridgeValidator(bridgeId_));
        (address approvalToken_, uint256 amount_) = validator.decodeDstSwap(txData_);
        v.finalDst = superRegistry.getAddress(keccak256("CORE_STATE_REGISTRY"));
        /// @dev validates the bridge data
        validator.validateTxData(
            IBridgeValidator.ValidateTxDataArgs(
                txData_,
                chainId,
                chainId,
                chainId,
                false,
                /// @dev to enter the if-else case of the bridge validator loop
                address(0),
                v.finalDst,
                approvalToken_
            )
        );

        /// @dev get the address of the bridge to send the txData to.
        v.to = superRegistry.getBridgeAddress(bridgeId_);
        (v.underlying, v.expAmount, v.maxSlippage) = _getFormUnderlyingFrom(payloadId_, index_);

        uint256 balanceBefore = IERC20(v.underlying).balanceOf(v.finalDst);
        if (approvalToken_ != NATIVE) {
            /// @dev approve the bridge to spend the approvalToken_.
            IERC20(approvalToken_).safeIncreaseAllowance(v.to, amount_);

            /// @dev execute the txData_.
            (bool success,) = payable(v.to).call(txData_);
            if (!success) revert Error.FAILED_TO_EXECUTE_TXDATA();
        } else {
            /// @dev execute the txData_.
            (bool success,) = payable(v.to).call{ value: amount_ }(txData_);
            if (!success) revert Error.FAILED_TO_EXECUTE_TXDATA_NATIVE();
        }
        uint256 balanceAfter = IERC20(v.underlying).balanceOf(v.finalDst);

        if (balanceAfter <= balanceBefore) {
            revert Error.INVALID_SWAP_OUTPUT();
        }

        /// @dev if actual underlying is less than expAmount adjusted
        /// with maxSlippage, invariant breaks
        if (balanceAfter - balanceBefore < ((v.expAmount * (10_000 - v.maxSlippage)) / 10_000)) {
            revert Error.MAX_SLIPPAGE_INVARIANT_BROKEN();
        }

        /// @dev updates swapped amount
        swappedAmount[payloadId_][index_] = balanceAfter - balanceBefore;

        /// @dev emits final event
        emit SwapProcessed(payloadId_, index_, bridgeId_, balanceAfter - balanceBefore);
    }

    /// @inheritdoc IDstSwapper
    function batchProcessTx(
        uint256 payloadId_,
        uint256[] calldata indices,
        uint8[] calldata bridgeIds_,
        bytes[] calldata txData_
    )
        external
        override
        onlySwapper
    {
        uint256 len = txData_.length;
        for (uint256 i; i < len;) {
            processTx(payloadId_, indices[i], bridgeIds_[i], txData_[i]);

            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc IDstSwapper
    function processFailedTx(
        uint256 payloadId_,
        uint256 superformId_,
        address interimToken_,
        uint256 amount_
    )
        public
        override
        onlySwapper
        nonReentrant
    {
        if (failedSwap[payloadId_][superformId_].amount != 0) {
            revert Error.FAILED_DST_SWAP_ALREADY_PROCESSED();
        }

        /// @dev updates swapped amount
        failedSwap[payloadId_][superformId_].amount = amount_;
        failedSwap[payloadId_][superformId_].interimToken = interimToken_;

        address finalDst = superRegistry.getAddress(keccak256("CORE_STATE_REGISTRY"));

        if (interimToken_ != NATIVE) {
            IERC20(interimToken_).safeTransfer(finalDst, amount_);
        } else {
            (bool success,) = payable(finalDst).call{ value: amount_ }("");
            if (!success) revert Error.FAILED_TO_SEND_NATIVE();
        }
        /// @dev emits final event
        emit SwapFailed(payloadId_, superformId_, interimToken_, amount_);
    }

    /// @inheritdoc IDstSwapper
    function batchProcessFailedTx(
        uint256 payloadId_,
        uint256[] calldata superformIds_,
        address[] calldata interimTokens_,
        uint256[] calldata amounts_
    )
        external
        override
        onlySwapper
    {
        uint256 len = superformIds_.length;
        for (uint256 i; i < len;) {
            processFailedTx(payloadId_, superformIds_[i], interimTokens_[i], amounts_[i]);

            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc IDstSwapper
    function getFailedSwap(
        uint256 payloadId_,
        uint256 superformId_
    )
        external
        view
        override
        returns (address interimToken, uint256 amount)
    {
        interimToken = failedSwap[payloadId_][superformId_].interimToken;
        amount = failedSwap[payloadId_][superformId_].amount;
    }

    /*///////////////////////////////////////////////////////////////
                        INTERNAL HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _getFormUnderlyingFrom(
        uint256 payloadId_,
        uint256 index_
    )
        internal
        view
        returns (address underlying_, uint256 amount_, uint256 maxSlippage_)
    {
        IBaseStateRegistry coreStateRegistry =
            IBaseStateRegistry(superRegistry.getAddress(keccak256("CORE_STATE_REGISTRY")));

        PayloadState currState = coreStateRegistry.payloadTracking(payloadId_);

        if (currState != PayloadState.STORED) {
            revert Error.INVALID_PAYLOAD_STATUS();
        }

        uint256 payloadHeader = coreStateRegistry.payloadHeader(payloadId_);
        bytes memory payload = coreStateRegistry.payloadBody(payloadId_);

        (,, uint8 multi,,,) = DataLib.decodeTxInfo(payloadHeader);

        if (multi == 1) {
            InitMultiVaultData memory data = abi.decode(payload, (InitMultiVaultData));

            if (index_ >= data.superformIds.length) {
                revert Error.INVALID_INDEX();
            }

            (address form_,,) = DataLib.getSuperform(data.superformIds[index_]);
            underlying_ = IERC4626Form(form_).getVaultAsset();
            maxSlippage_ = data.maxSlippage[index_];
            amount_ = data.amounts[index_];
        } else {
            if (index_ != 0) {
                revert Error.INVALID_INDEX();
            }

            InitSingleVaultData memory data = abi.decode(payload, (InitSingleVaultData));
            (address form_,,) = DataLib.getSuperform(data.superformId);
            underlying_ = IERC4626Form(form_).getVaultAsset();
            maxSlippage_ = data.maxSlippage;
            amount_ = data.amount;
        }
    }

    /*///////////////////////////////////////////////////////////////
                            EMERGENCY FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @dev EMERGENCY_ADMIN ONLY FUNCTION.
    /// @dev allows admin to withdraw lost tokens in the smart contract.
    /// @param tokenContract_        address of the token contract
    /// @param amount_               amount of tokens to withdraw
    function emergencyWithdrawToken(address tokenContract_, uint256 amount_) external onlyEmergencyAdmin {
        IERC20 tokenContract = IERC20(tokenContract_);

        /// note: transfer the token from address of this contract
        /// note: to address of the user (executing the withdrawToken() function)
        tokenContract.safeTransfer(msg.sender, amount_);
    }

    /// @dev EMERGENCY_ADMIN ONLY FUNCTION.
    /// @dev allows admin to withdraw lost native tokens in the smart contract.
    /// @param amount_               amount of tokens to withdraw
    function emergencyWithdrawNativeToken(uint256 amount_) external onlyEmergencyAdmin {
        (bool success,) = payable(msg.sender).call{ value: amount_ }("");
        if (!success) revert Error.NATIVE_TOKEN_TRANSFER_FAILURE();
    }
}
