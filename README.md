## 🔒 SiuToken & DAO Governance Smart Contract

A full-featured ERC-20 token and DAO system developed entirely in Solidity.  
This project includes dynamic fee distribution, token locking, batch airdrops, and on-chain governance with weighted voting.

### 🚀 Key Highlights

- ✅ **Custom ERC-20 Token** with fee logic and minting:  
  `1,000,000 SIU` total supply, with dynamic 1% transfer fee split across two addresses (40% / 60%).

- 🔐 **Token Locking Mechanism**:  
  Users can lock their tokens for a specific duration, preventing premature transfer.

- 🎯 **Fee Distribution Logic**:  
  Transfer fee automatically split and routed to multiple addresses on every transaction.

- 📦 **Batch Airdrop Tool**:  
  Gas-efficient batch distribution of SIU tokens to multiple addresses.

- 🗳️ **On-Chain DAO Voting System**:  
  SIU token holders can create proposals and vote based on real-time token balances.  
  Vote weights are calculated in raw token units (`wei`) and displayed in human-readable format (`SIU`).

- 📈 **Execution-Ready & Testnet Deployed**:  
  Contracts have been successfully deployed and tested on the Sepolia Ethereum testnet, using Remix + MetaMask.

### 📊 Data & Outcome

- ✅ Over `10+` integrated smart contract functions across `ERC-20`, `lock logic`, `DAO governance`, and `airdrop`.
- ✅ Fully written in low-level Solidity (no frameworks like Hardhat or Foundry), demonstrating in-depth manual control.
- ✅ Codebase audited manually for overflow, access control, and event logging logic.
- ✅ Real voting tested using simulated accounts with varying balances.
- ✅ Verified on testnet — proposals were created, voted, and executed without errors.

---

📄 [📂 Full PDF Report](https://drive.google.com/file/d/1ZEI7BnvRLfd9WSh-Igyba2ojisQhTBeQ/view?usp=sharing)  
🔗 Smart Contract Source Code can see in GitHub repository main root (Sol)

> This is not just a token — it’s a fully working **DAO demo** for real-world decentralized decision making, built from scratch by a student in FinTech.
