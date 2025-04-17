// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SiuToken
 * A very simplified ERC20 token for demonstration. 
 * Name: "SiuToken"
 * Symbol: "SIU"
 * Decimals: 18
 *
 * NOTE: 
 * For production, consider importing OpenZeppelin's ERC20 implementation 
 * instead of rolling your own.
 */
contract SiuToken {
    string public name = "SiuToken";
    string public symbol = "SIU";
    uint8 public decimals = 18;
    
    uint256 public totalSupply;
    
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor(uint256 _initialSupply) {
        // Mint the initial supply to the deployer
        totalSupply = _initialSupply * 10**uint256(decimals);
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
    
    function transfer(address to, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "Not enough balance");
        _transfer(msg.sender, to, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        require(balances[sender] >= amount, "Not enough balance");
        require(allowances[sender][msg.sender] >= amount, "Allowance exceeded");
        
        allowances[sender][msg.sender] -= amount;
        _transfer(sender, recipient, amount);
        return true;
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(to != address(0), "Cannot transfer to the zero address");
        
        balances[from] -= amount;
        balances[to] += amount;
        
        emit Transfer(from, to, amount);
    }
}


/**
 * @title SiuDAO
 * A simplified DAO that uses SIU tokens for voting.
 * 
 * Features:
 * - Create proposals
 * - Vote "yes" or "no"
 * - Track yes/no votes in raw wei amounts, but expose “human-readable” SIU in getProposal
 */
contract SiuDAO {
    struct Proposal {
        uint256 id;
        string description;  // short text describing the proposal
        uint256 yesVotes;    // total "yes" votes in raw token units (wei)
        uint256 noVotes;     // total "no" votes in raw token units (wei)
        bool executed;       // if the proposal has been executed
        uint256 endTime;     // timestamp after which no more voting
        address proposer;    // address who created the proposal
    }
    
    SiuToken public siuToken;                        // reference to the SiuToken contract
    uint256 public nextProposalId;                   // incremental ID for proposals
    mapping(uint256 => Proposal) public proposals;   // store proposals
    mapping(uint256 => mapping(address => bool)) public hasVoted;  
    // hasVoted[proposalId][voter] -> bool
    
    event ProposalCreated(uint256 proposalId, string description, address proposer);
    event Voted(uint256 proposalId, address voter, bool support, uint256 votes);
    event ProposalExecuted(uint256 proposalId);
    
    constructor(address _siuTokenAddress) {
        siuToken = SiuToken(_siuTokenAddress);
    }
    
    /**
     * @dev Create a new proposal.
     * @param _description short description of the proposal
     * @param _votingPeriodInSeconds how many seconds the voting will remain open
     */
    function createProposal(string memory _description, uint256 _votingPeriodInSeconds) external {
        require(_votingPeriodInSeconds > 0, "Voting period must be > 0");
        
        proposals[nextProposalId] = Proposal({
            id: nextProposalId,
            description: _description,
            yesVotes: 0,
            noVotes: 0,
            executed: false,
            endTime: block.timestamp + _votingPeriodInSeconds,
            proposer: msg.sender
        });
        
        emit ProposalCreated(nextProposalId, _description, msg.sender);
        nextProposalId++;
    }
    
    /**
     * @dev Vote on a proposal. Each address can only vote once per proposal.
     * Your voting power = your current SIU token balance at the time of voting (in wei).
     * @param _proposalId ID of the proposal
     * @param _support true = vote yes, false = vote no
     */
    function vote(uint256 _proposalId, bool _support) external {
        Proposal storage proposal = proposals[_proposalId];
        
        require(block.timestamp < proposal.endTime, "Voting period ended");
        require(!proposal.executed, "Proposal already executed");
        require(!hasVoted[_proposalId][msg.sender], "Already voted on this proposal");
        
        uint256 voterBalance = siuToken.balanceOf(msg.sender);
        require(voterBalance > 0, "No SIU token balance to vote with");
        
        if (_support) {
            proposal.yesVotes += voterBalance;
        } else {
            proposal.noVotes += voterBalance;
        }
        
        hasVoted[_proposalId][msg.sender] = true;
        
        emit Voted(_proposalId, msg.sender, _support, voterBalance);
    }
    
    /**
     * @dev Execute the proposal if the voting period ended. 
     * In this sample, "execution" does nothing except mark the proposal as executed.
     * Real DAO logic would happen here (e.g., transferring funds, calling external contracts).
     * @param _proposalId ID of the proposal
     */
    function executeProposal(uint256 _proposalId) external {
        Proposal storage proposal = proposals[_proposalId];
        
        require(block.timestamp >= proposal.endTime, "Voting period not ended");
        require(!proposal.executed, "Proposal already executed");
        
        // Mark as executed
        proposal.executed = true;
        
        emit ProposalExecuted(_proposalId);
        // Additional logic could go here (e.g. passing if yesVotes > noVotes, etc.)
    }
    
    /**
     * @dev Get proposal data in a more user-friendly way.
     * Convert raw wei votes to "actual SIU" by dividing by 10**18.
     */
    function getProposal(uint256 _proposalId)
        external
        view
        returns (
            string memory description,
            uint256 realYesVotes, 
            uint256 realNoVotes,
            bool executed,
            uint256 endTime,
            address proposer
        )
    {
        Proposal memory p = proposals[_proposalId];
        
        // Convert from wei units to SIU 
        // 1 SIU = 10^18 wei (since decimals = 18)
        realYesVotes = p.yesVotes / 10**18;
        realNoVotes  = p.noVotes  / 10**18;
        
        return (
            p.description,
            realYesVotes,
            realNoVotes,
            p.executed,
            p.endTime,
            p.proposer
        );
    }
}