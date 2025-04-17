// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SiuToken is ERC20 {
    uint256 public fee = 1; // Fee percentage (1%)
    mapping(address => uint256) public feeRecipients; // Address and percentage for fee distribution
    uint256 public totalFeePercentage = 100; // Total fee percentage must equal 100
    mapping(address => uint256) public lockTime; // Lock time for each address

    // Constructor: Initialize supply and fee distribution addresses3
    constructor(address initialOwner) ERC20("SiuToken", "SIU") {
        // Initialize fee distribution addresses and their percentages
        feeRecipients[0x61750e8c9D499F9b5C2D0460A584e22046f0c31F] = 40; // Address A - 40%
        feeRecipients[0x95d80056911B5140f7E932f4931FD1dFFb11d744] = 60; // Address B - 60%
        _mint(initialOwner, 1000000 * 10**decimals()); // Mint initial supply to the owner
    }

    // Custom transfer function with fee distribution
    function transfer(address to, uint256 amount) public override returns (bool) {
        uint256 feeAmount = (amount * fee) / 100; // Calculate fee
        uint256 amountAfterFee = amount - feeAmount; // Remaining amount after fee deduction

        // Distribute fees to fee recipients
        for (uint256 i = 0; i < 2; i++) {
            address recipient = (i == 0)
                ? 0x61750e8c9D499F9b5C2D0460A584e22046f0c31F
                : 0x95d80056911B5140f7E932f4931FD1dFFb11d744;
            uint256 recipientFee = (feeAmount * feeRecipients[recipient]) / 100;
            _transfer(msg.sender, recipient, recipientFee);
        }

        _transfer(msg.sender, to, amountAfterFee); // Transfer the remaining amount to the recipient
        return true;
    }

    // Set fee percentage (open for all users)
    function setFee(uint256 newFee) public {
        require(newFee <= 100, "Fee too high"); // Fee cannot exceed 100%
        fee = newFee;
    }

    // Lock tokens for a specific period
    function lockTokens(uint256 lockPeriod) public {
        require(balanceOf(msg.sender) > 0, "No tokens to lock"); // Ensure sender has tokens
        lockTime[msg.sender] = block.timestamp + lockPeriod; // Set lock time
    }

    // Transfer with lock check
    function transferWithLockCheck(address to, uint256 amount) public returns (bool) {
        require(block.timestamp > lockTime[msg.sender], "Tokens are locked"); // Ensure tokens are unlocked
        return transfer(to, amount);
    }

    // Airdrop function: Batch transfer tokens
    function airdrop(address[] memory recipients, uint256 amount) public {
        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amount);
        }
    }
}