// SPDX-License-Identifier: GPL-2.0-or-later
// TokenX Contracts v1.0.2 (contracts/InvestmentTokenM.sol)
pragma solidity 0.8.24;

import {ERC20Mintable} from "../extensions/ERC20Mintable.sol";
import {ERC20TransferLimit} from "../extensions/ERC20TransferLimit.sol";
import {EmergencyWithdrawable} from "../extensions/EmergencyWithdrawable.sol";
import {ERC20AllowListableProxy} from "../extensions/ERC20AllowListableProxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/**
 * @dev {ERC20} token, including:
 *
 *  - Ability for holders to burn (destroy) their tokens
 *  - The owner is allowed to mint token.
 *  - The owner is allowed to stop all token transfers.
 *  - The owner is allowed to set a transfer limit for a specific address.
 *  - The owner is allowed to add a specific address to allowlist for transfer and receive token.
 *
 * This contract uses {Ownable} to include access control capabilities.
 * This contract uses {Pausable} to include pause capabilities.
 * This contract uses {ERC20Burnable} to include burn capabilities.
 * This contract uses {ERC20Mintable} to include mint control capabilities.
 * This contract uses {ERC20TransferLimit} to include transfer limit control capabilities.
 * This contract uses {ERC20AllowListableProxy} to include transfer and receive control capabilities.
 * This contract uses {EmergencyWithdrawable} to include emergency withdraw capabilities.
 */
contract InvestmentTokenM is Ownable, Pausable, ERC20Burnable, ERC20Mintable, ERC20TransferLimit, ERC20AllowListableProxy, EmergencyWithdrawable {
    constructor(string memory name_, string memory symbol_, address allowlistRegistry_) ERC20(name_, symbol_) {
        _setAllowlistRegistry(allowlistRegistry_);
    }

    /**
     * @dev Throws if sender or receiver are not allowlisted account.
     */
    modifier onlyAllowlist(address sender, address receiver) {
        address _msgSender = _msgSender();
        if (_msgSender != owner()) {
            bool _isAllowlist = isAllowlist(sender) && isAllowlist(receiver) && isAllowlist(_msgSender);
            require(_isAllowlist, "InvestmentToken: account are not allowlisted");
        }
        _;
    }

    /**
     * @dev See {ERC20AllowListableProxy-_setAllowlistRegistry}
     * 
     * Set the `allowlistRegistry` contract address.
     * 
     * Emits a {AllowlistRegistryChanged} event indicating allowlist registry has changed.
     *
     * Requirements:
     *
     * - the caller must be owner.
     */
    function setAllowlistRegistry(address allowlistRegistry) external virtual onlyOwner {
        _setAllowlistRegistry(allowlistRegistry);
    }

    /**
     * @dev See {ERC20TransferLimit-_enableTransferLimitable}
     * 
     * Enables transfer limits.
     * 
     * Emits a {EnableERC20TransferLimit} event indicating transfer limit are enabled.
     *
     * Requirements:
     *
     * - the caller must be owner.
     */
    function enableTransferLimitable() external virtual onlyOwner {
        _enableTransferLimitable();
    }

    /**
     * @dev See {ERC20TransferLimit-_disableTransferLimitable}
     *
     * Disables transfer limits.
     * 
     * Emits a {DisableERC20TransferLimit} event indicating transfer limit are disabled.
     * 
     * Requirements:
     * 
     * - the caller must be owner.
     */
    function disableTransferLimitable() external virtual onlyOwner {
        _disableTransferLimitable();
    }

    /**
     * @dev See {ERC20TransferLimit-_setAccountTransferLimit}.
     *
     * Sets an account's transfer limit.
     *
     * Emits an {SetAccountTransferLimit} event indicating that account has set transfer limit.
     *
     * Requirements:
     * 
     * - the caller must be owner.
     */
    function setAccountTransferLimit(address account, uint256 amount) external virtual onlyOwner {
        _setAccountTransferLimit(account, amount);
    }

    /**
     * @dev See {ERC20TransferLimit-_unsetAccountTransferLimit}.
     *
     * Unsets an account's transfer limit.
     *
     * Emits an {UnsetAccountTransferLimit} event indicating that account has unset transfer limit.
     *
     * Requirements:
     * 
     * - the caller must be owner.
     */
    function unsetAccountTransferLimit(address account) external virtual onlyOwner {
        _unsetAccountTransferLimit(account);
    }

    /**
     * @dev See {ERC20TransferLimit-_increaseAccountTransferLimit}.
     *
     * Increases the transfer limit for a specific account.
     *
     * Emits an {IncreaseAccountTransferLimit} event indicating that the account's transfer limit has been increased.
     *
     * Requirements:
     * 
     * - the caller must be owner.
     */
    function increaseAccountTransferLimit(address account, uint256 amount) external virtual onlyOwner {
        _increaseAccountTransferLimit(account, amount);
    }

    /**
     * @dev See {ERC20TransferLimit-_decreaseAccountTransferLimit}.
     *
     * Decreases the transfer limit for a specific account.
     *
     * Emits an {IncreaseAccountTransferLimit} event indicating that the account's transfer limit has been decreased.
     *
     * Requirements:
     * 
     * - the caller must be owner.
     */
    function decreaseAccountTransferLimit(address account, uint256 amount) external virtual onlyOwner {
        _decreaseAccountTransferLimit(account, amount);
    }

    /**
     * @dev See {ERC20Mintable-_mint}
     * 
     * Creates `amount` new tokens for `owner`.
     *
     * Requirements:
     *
     * - the caller must be owner.
     * - `_mintable` must not be renounced.
     */
    function mint(uint256 amount) external virtual onlyOwner whenMintable {
        _mint(msg.sender, amount);
    }

    /**
     * @dev See {ERC20Mintable-_renounceMintable}
     * 
     * Leaves the contract without mint capabilities. It will not be possible to call
     * `mint` functions anymore. Can only be called by the current owner and mintable is not renounced yet.
     *
     * Emits an {RenouncedMintable} event indicating the mintable renonuced.
     *
     * NOTE: Renouncing mintable will leave the contract without mint capabilities,
     * thereby removing any functionality that is only available when mintable.
     *
     * Requirements:
     *
     * - the caller must be owner.
     * - `_mintable` must not be renounced.
     */
    function renounceMintable() external virtual onlyOwner whenMintable {
        _renounceMintable();
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     * - the caller and `to` must be allowlisted account.
     * - the contract must not be paused.
     * - if transfer limits are enabled on an account, the caller must have a transfer limit at least equal to `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override onlyAllowlist(msg.sender, to) validateTransferLimit(msg.sender, amount) whenNotPaused returns (bool) {
        return super.transfer(to, amount);
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - the caller and `spender` must be allowlisted account.
     * - the contract must not be paused.
     */
    function approve(address spender, uint256 amount) public virtual override onlyAllowlist(msg.sender, spender) whenNotPaused returns (bool) {
        return super.approve(spender, amount);
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for `from`'s tokens of at least `amount`.
     * - the caller and `spender` must be allowlisted account.
     * - the contract must not be paused.
     * - if transfer limits are enabled on an `from` account, the caller must have a transfer limit at least equal to `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override onlyAllowlist(from, to) validateTransferLimit(from, amount) whenNotPaused returns (bool) {
        return super.transferFrom(from, to, amount);
    }

    /**
     * @dev See {IERC20-increaseAllowance}.
     * 
     * Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - the caller and `spender` must be allowlisted account.
     * - the contract must not be paused.
     */
    function increaseAllowance(address spender, uint256 addedValue) public override virtual onlyAllowlist(msg.sender, spender) whenNotPaused returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    /**
     * @dev See {IERC20-decreaseAllowance}.
     * 
     * Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     * - the caller and `spender` must be allowlisted account.
     * - the contract must not be paused.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public override virtual onlyAllowlist(msg.sender, spender) whenNotPaused returns (bool) {
        return super.decreaseAllowance(spender, subtractedValue);
    }

    /**
     * @dev See {ERC20-_burn}.
     * 
     * Destroys `amount` tokens from the caller.
     *
     * Requirements:
     *
     * - the caller must be allowlisted account.
     * - the contract must not be paused.
     */
    function burn(uint256 amount) public virtual override onlyAllowlist(msg.sender, msg.sender) whenNotPaused {
        super.burn(amount);
    }

    /**
     * @dev See {ERC20-_burn} and {ERC20-allowance}.
     * 
     * Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * Requirements:
     *
     * - the caller must have allowance for `accounts`'s tokens of at least
     * `amount`.
     * - the caller and `account` must be allowlisted account.
     * - the contract must not be paused.
     */
    function burnFrom(address account, uint256 amount) public virtual override onlyAllowlist(msg.sender, account) whenNotPaused {
        super.burnFrom(account, amount);
    }

    /**
     * @dev Force transfer by the owner.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - `to` cannot be the zero address.
     * - `to` must be allowlisted account.
     * - the caller must be owner.
     * - the contract must not be paused.
     */
    function adminTransfer(address from, address to, uint256 amount) external virtual onlyOwner {
        _transfer(from, to, amount);
    }

    /**
     * @dev Force burn by the owner.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have a balance of at least `amount`.
     * - the caller must be owner.
     */
     function adminBurn(address account, uint256 amount) external virtual onlyOwner {
         _burn(account, amount);
     }

    /**
     * @dev See {ERC20Pausable} and {Pausable-_pause}.
     * 
     * Pauses all token transfers.
     *
     * Requirements:
     *
     * - the caller must be owner.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev See {ERC20Pausable} and {Pausable-_unpause}.
     * 
     * Unpauses all token transfers.
     *
     * Requirements:
     *
     * - the caller must be owner.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev See {EmergencyWithdrawable-_emergencyWithdrawToken}.
     * 
     * Withdraw ERC20 `token` from (this) contract to owner.
     *
     * Requirements:
     *
     * - the caller must be owner.
     */
    function emergencyWithdrawToken(address token) external onlyOwner {
        _emergencyWithdrawToken(owner(), token);
    }
}
