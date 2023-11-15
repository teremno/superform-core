// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.21;

library Error {

    //////////////////////////////////////////////////////////////
    //                  CONFIGURATION ERRORS                    //
    //////////////////////////////////////////////////////////////
    ///@notice errors thrown in protocol setup
    
    /// @dev thrown when there is an array length mismatch
    error ARRAY_LENGTH_MISMATCH();

    /// @dev thrown if chain id exceeds max(uint64)
    error BLOCK_CHAIN_ID_OUT_OF_BOUNDS();

    /// @dev thrown when not possible to revoke a role in broadcasting
    error CANNOT_REVOKE_NON_BROADCASTABLE_ROLES();

    /// @dev thrown when not possible to revoke last admin
    error CANNOT_REVOKE_LAST_ADMIN();

    /// @dev thrown when trying to set again pseudo immutables in SuperRegistry
    error DISABLED();

    /// @dev thrown if rescue delay is not yet set for a chain
    error DELAY_NOT_SET();

    /// @dev thrown if wormhole relayer is not set
    error RELAYER_NOT_SET();

    //////////////////////////////////////////////////////////////
    //                  AUTHORIZATION ERRORS                    //
    //////////////////////////////////////////////////////////////
    ///@notice errors thrown when functions cannot be called

    /// COMMON AUTHORIZATION ERRORS

    /// @dev thrown when msg.sender is not a valid amb implementation
    error NOT_AMB_IMPLEMENTATION();

    /// @dev thrown when msg.sender is not an allowed broadcaster
    error NOT_ALLOWED_BROADCASTER();

    /// @dev thrown when msg.sender is not broadcast amb implementation
    error NOT_BROADCAST_AMB_IMPLEMENTATION();

    /// @dev thrown when msg.sender is not broadcast state registry
    error NOT_BROADCAST_REGISTRY();

    /// @dev thrown when msg.sender is not core state registry
    error NOT_CORE_STATE_REGISTRY();

    /// @dev thrown when msg.sender is not emergency admin
    error NOT_EMERGENCY_ADMIN();

    /// @dev thrown when msg.sender is not emergency queue
    error NOT_EMERGENCY_QUEUE();

    /// @dev thrown when msg.sender is not minter
    error NOT_MINTER();

    /// @dev thrown when msg.sender is not minter state registry
    error NOT_MINTER_STATE_REGISTRY_ROLE();

    /// @dev thrown when msg.sender is not paymaster
    error NOT_PAYMASTER();

    /// @dev thrown when msg.sender is not payment admin
    error NOT_PAYMENT_ADMIN();

    /// @dev thrown when msg.sender is not protocol admin
    error NOT_PROTOCOL_ADMIN();

    /// @dev thrown when msg.sender is not state registry
    error NOT_STATE_REGISTRY();

    /// @dev thrown when msg.sender is not super registry
    error NOT_SUPER_REGISTRY();

    /// @dev thrown when msg.sender is not superform router
    error NOT_SUPERFORM_ROUTER();

    /// @dev thrown when msg.sender is not a superform
    error NOT_SUPERFORM();

    /// @dev thrown when msg.sender is not superform factory
    error NOT_SUPERFORM_FACTORY();

    /// @dev thrown when msg.sender is not timelock form
    error NOT_TIMELOCK_SUPERFORM();

    /// @dev thrown when msg.sender is not timelock state registry
    error NOT_TIMELOCK_STATE_REGISTRY();

    /// @dev thrown if msg.sender is not user or disputer
    error NOT_VALID_DISPUTER();

    /// @dev thrown if the msg.sender is not privileged caller
    error NOT_PRIVILEGED_CALLER(bytes32 role);

    /// STATE REGISTRY AUTHORIZATION ERRORS

    /// @dev layerzero adapter specific error, when caller not layerzero endpoint
    error CALLER_NOT_ENDPOINT();

    /// @dev hyperlane adapter specific error, when caller not hyperlane mailbox
    error CALLER_NOT_MAILBOX();

    /// @dev wormhole relayer specific error, when caller not wormhole relayer
    error CALLER_NOT_RELAYER();

    /// @dev thrown when src chain sender is not valid
    error INVALID_SRC_SENDER();

    //////////////////////////////////////////////////////////////
    //                  INPUT VALIDATION ERRORS                 //
    //////////////////////////////////////////////////////////////
    ///@notice errors thrown when input variables are not valid

    /// COMMON INPUT VALIDATION ERRORS

    /// @dev error thrown when address input is address 0
    error ZERO_ADDRESS();

    /// @dev error thrown when amount input is 0
    error ZERO_AMOUNT();

    /// @dev error thrown when value input is 0
    error ZERO_INPUT_VALUE();

    /// @dev thrown when user pays zero
    error ZERO_MSG_VALUE();

    /// @dev error thrown when amb ids length is 0
    error ZERO_AMB_ID_LENGTH();

    /// @dev thrown if payload id does not exist
    error INVALID_PAYLOAD_ID();

    /// SUPERFORM ROUTER INPUT VALIDATION ERRORS

    /// @dev thrown when the vaults data is invalid
    error INVALID_SUPERFORMS_DATA();

    /// @dev thrown if receiver address is not set when the contract is a smart contract wallet
    error RECEIVER_ADDRESS_NOT_SET();

    /// SUPERFORM FACTORY INPUT VALIDATION ERRORS

    /// @dev thrown when form id is larger than max uint16
    error INVALID_FORM_ID();

    /// @dev thrown when a form is not ERC165 compatible
    error ERC165_UNSUPPORTED();

    /// @dev thrown when a form is not FORM interface compatible
    error FORM_INTERFACE_UNSUPPORTED();

    /// @dev error thrown when beacon id already exists
    error FORM_IMPLEMENTATION_ID_ALREADY_EXISTS();

    /// @dev thrown when a form does not exist
    error FORM_DOES_NOT_EXIST();

    /// @dev thrown when superform not on factory
    error SUPERFORM_ID_NONEXISTENT();

    /// @dev thrown when same vault and beacon is used to create new superform
    error VAULT_FORM_IMPLEMENTATION_COMBINATION_EXISTS();

    /// FORM INPUT VALIDATION ERRORS

    /// @dev in case of no txData, if liqData.token != collateral. In case of txData, if token output of swap ==
    /// vault.asset()
    error DIFFERENT_TOKENS();

    /// @dev thrown when the amount in direct deposit is not correct
    error DIRECT_DEPOSIT_INVALID_DATA();

    /// @dev thrown when the collateral in direct withdraw is not correct
    error DIRECT_WITHDRAW_INVALID_COLLATERAL();

    /// @dev thrown when the amount in direct withdraw is not correct
    error DIRECT_WITHDRAW_INVALID_LIQ_REQUEST();

    /// @dev thrown when the amount in xchain withdraw is not correct
    error XCHAIN_WITHDRAW_INVALID_LIQ_REQUEST();

    /// LIQUIDITY BRIDGE INPUT VALIDATION ERRORS

    /// @dev when a certain action of the user is not allowed given the txData provided
    error INVALID_ACTION();

    /// @dev thrown when in deposits, the liqDstChainId doesn't match the stateReq dstChainId
    error INVALID_DEPOSIT_LIQ_DST_CHAIN_ID();

    /// @dev thrown if index is invalid
    error INVALID_INDEX();

    /// @dev is emitted when the chain id in the txdata is invalid
    error INVALID_TXDATA_CHAIN_ID();

    /// @dev thrown when the validation of bridge txData fails due to a destination call present
    error INVALID_TXDATA_NO_DESTINATIONCALL_ALLOWED();

    /// @dev thrown the when validation of bridge txData fails due to wrong receiver
    error INVALID_TXDATA_RECEIVER();

    /// @dev thrown when the validation of bridge txData fails due to wrong token
    error INVALID_TXDATA_TOKEN();

    /// @dev error thrown when txData must be present (in case of xChain acitons)
    error NO_TXDATA_PRESENT();

    /// STATE REGISTRY INPUT VALIDATION ERRORS

    /// @dev thrown if payload is being updated with final amounts length different than amounts length
    error DIFFERENT_PAYLOAD_UPDATE_AMOUNTS_LENGTH();

    /// @dev thrown if payload is being updated with tx data length different than liq data length
    error DIFFERENT_PAYLOAD_UPDATE_TX_DATA_LENGTH();

    /// @dev thrown if a duplicate proof amb is found
    error DUPLICATE_PROOF_BRIDGE_ID();

    /// @dev thrown when broadcast finality for wormhole is invalid
    error INVALID_BROADCAST_FINALITY();

    /// @dev thrown if ambId is not valid leading to an address 0 of the implementation
    error INVALID_BRIDGE_ID();

    /// @dev is emitted when the chain id brought in the cross chain message is invalid
    error INVALID_CHAIN_ID();

    /// @dev thrown if payload update amount mismatch with dst swapper amount
    error INVALID_DST_SWAP_AMOUNT();

    /// @dev thrown if message amb and proof amb are the same
    error INVALID_PROOF_BRIDGE_ID();

    /// @dev thrown if the rescue data lengths are invalid
    error INVALID_RESCUE_DATA();

    /// @dev thrown if the delay is invalid
    error INVALID_TIMELOCK_DELAY();

    /// @dev thrown if the amounts being sent in update payload mean a negative slippage
    error NEGATIVE_SLIPPAGE();

    /// @dev thrown when slippage is outside of bounds
    error SLIPPAGE_OUT_OF_BOUNDS();

    /// SUPERPOSITIONS INPUT VALIDATION ERRORS

    /// @dev thrown if src senders mismatch in state sync
    error SRC_SENDER_MISMATCH();

    /// @dev thrown if src tx types mismatch in state sync
    error SRC_TX_TYPE_MISMATCH();

    //////////////////////////////////////////////////////////////
    //                  EXECUTION ERRORS                        //
    //////////////////////////////////////////////////////////////
    ///@notice errors thrown due to function execution logic

    /// COMMON EXECUTION ERRORS
    /// @dev thrown if the broadcast payload is invalid
    error INVALID_BROADCAST_PAYLOAD();

    /// @dev thrown if the broadcast fee is invalid
    error INVALID_BROADCAST_FEE();

    /// @dev thrown if the underlying collateral mismatches
    error INVALID_DEPOSIT_TOKEN();

    /// @dev thrown when the payload cannot be decoded
    error INVALID_PAYLOAD();

    /// LIQUIDITY BRIDGE EXECUTION ERRORS
    /// @dev thrown when dst swap output is less than minimum expected
    error INVALID_SWAP_OUTPUT();

    /// @dev thrown when try to process dst swap for same payload id
    error DST_SWAP_ALREADY_PROCESSED();

    /// @dev error thrown if we try to decode the final swap output token in a xChain liquidity bridging action
    error CANNOT_DECODE_FINAL_SWAP_OUTPUT_TOKEN();

    /// STATE REGISTRY EXECUTION ERRORS

    /// @dev thrown if the payload status is invalid
    error INVALID_PAYLOAD_STATUS();

    /// @dev thrown if payload type is invalid
    error INVALID_PAYLOAD_TYPE();

    /// @dev thrown if update payload function was called on a wrong payload
    error INVALID_PAYLOAD_UPDATE_REQUEST();

    /// @dev is thrown if the payload hash is zero during `retryMessage` on Layezero implementation
    error ZERO_PAYLOAD_HASH();

    /// @dev is thrown if the payload hash is invalid during `retryMessage` on Layezero implementation
    error INVALID_PAYLOAD_HASH();

    /// @dev thrown when payload is not unique
    error DUPLICATE_PAYLOAD();

    /// @dev is thrown is payload is already updated (during xChain deposits)
    error PAYLOAD_ALREADY_UPDATED();

    /// @dev is thrown is payload is already processed
    error PAYLOAD_ALREADY_PROCESSED();

    /// @dev thrown if payload is not in UPDATED state
    error PAYLOAD_NOT_UPDATED();

    /// @dev thrown if withdrawal TX_DATA cannot be updated
    error CANNOT_UPDATE_WITHDRAW_TX_DATA();

    /// @dev thrown when withdrawl token is not updated
    error WITHDRAW_TOKEN_NOT_UPDATED();

    /// @dev thrown if withdrawal TX_DATA is not updated
    error WITHDRAW_TX_DATA_NOT_UPDATED();

    /// @dev thrown when src chain is blocked from messaging
    error INVALID_SRC_CHAIN_ID();

    /// @dev thrown if message failed to reach the specified level of quorum needed
    error INSUFFICIENT_QUORUM();

    /// @dev thrown if not enough native fees is paid for amb to send the message
    error CROSS_CHAIN_TX_UNDERPAID();

    /// @dev thrown if the rescue passed dispute deadline
    error DISPUTE_TIME_ELAPSED();

    /// @dev thrown if the rescue is still in timelocked state
    error RESCUE_LOCKED();

    /// @dev thrown when trying to finalize the payload but the withdraw is still locked
    error LOCKED();

    /// @dev thrown when unlock has already been requested - cooldown period didn't pass yet
    error WITHDRAW_COOLDOWN_PERIOD();

    /// @dev thrown when the bridge tokens haven't arrived to destination
    error BRIDGE_TOKENS_PENDING();

    /// @dev thrown when the native tokens transfer has failed
    error NATIVE_TOKEN_TRANSFER_FAILURE();

    /// LIQUIDITY HANDLER EXECUTION ERRORS
    /// @dev thrown if liquidity bridge fails for erc20 or native tokens
    error FAILED_TO_EXECUTE_TXDATA(address token);

    /// @dev thrown if native amount is not at least equal to the amount in the request
    error INSUFFICIENT_NATIVE_AMOUNT();

    /// @dev thrown if rescue is already proposed
    error RESCUE_ALREADY_PROPOSED();

    /// @dev thrown if DstSwapper fails to send native tokens to CoreStateRegistry
    error FAILED_TO_SEND_NATIVE();

    /// @dev thrown when actual amount recieved is less than the ideal amount adjusted with max slippage
    error MAX_SLIPPAGE_INVARIANT_BROKEN();

    /// @dev thrown when the failed dstSwap is already updated
    error FAILED_DST_SWAP_ALREADY_UPDATED();

    /// @dev thrown when the failed dstSwap is already processed
    error FAILED_DST_SWAP_ALREADY_PROCESSED();

    /// FORM EXECUTION ERRORS
    /// @dev thrown when the allowance in direct deposit is not correct
    error DIRECT_DEPOSIT_INSUFFICIENT_ALLOWANCE();

    /// @dev if implementation formBeacon is PAUSED then users cannot perform any action
    error PAUSED();

    /// @dev thrown in KYCDAO form if no KYC token is present
    error NO_VALID_KYC_TOKEN();

    /// PAYMENT HELPER EXECUTION ERRORS
    /// @dev thrown when chainlink is reporting an improper price
    error CHAINLINK_MALFUNCTION();

    /// @dev thrown when chainlink is reporting an incomplete round
    error CHAINLINK_INCOMPLETE_ROUND();

    /// EMERGENCY QUEUE EXECUTION ERRORS
    /// @dev thrown when the form has insufficient balance for emergency withdraw
    error EMERGENCY_WITHDRAW_INSUFFICIENT_BALANCE();

    /// @dev thrown when emergency withdraw is already processed
    error EMERGENCY_WITHDRAW_PROCESSED_ALREADY();

    /// @dev thrown when emergency withdraw is not queued
    error EMERGENCY_WITHDRAW_NOT_QUEUED();

    /// SUPERPOSITIONS EXECUTION ERRORS
    /// @dev thrown when the uri cannot be updated
    error DYNAMIC_URI_FROZEN();

    /// @dev thrown if tx history is not found while state sync
    error TX_HISTORY_NOT_FOUND();

    /// PAYMASTER EXECUTION ERRORS
    /// @dev thrown when payment withdrawal fails
    error FAILED_WITHDRAW();
}