// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReferralBonus {
    struct Referrer {
        uint256 tokensEarned;
        uint256 referralsCount;
    }

    address public owner;
    mapping(address => Referrer) public referrers;
    uint256 public totalTokens;
    uint256 public tokenPerReferral;

    event ReferralMade(address indexed referrer, address indexed newLearner);
    event TokensClaimed(address indexed referrer, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    constructor(uint256 _tokenPerReferral) {
        owner = msg.sender;
        tokenPerReferral = _tokenPerReferral;
    }

    function updateTokenPerReferral(uint256 _newAmount) external onlyOwner {
        tokenPerReferral = _newAmount;
    }

    function addReferral(address _referrer, address _newLearner) external onlyOwner {
        require(_referrer != _newLearner, "A referrer cannot refer themselves");
        require(_newLearner != address(0), "Invalid learner address");

        referrers[_referrer].tokensEarned += tokenPerReferral;
        referrers[_referrer].referralsCount += 1;
        totalTokens += tokenPerReferral;

        emit ReferralMade(_referrer, _newLearner);
    }

    function claimTokens() external {
        uint256 amount = referrers[msg.sender].tokensEarned;
        require(amount > 0, "No tokens to claim");

        referrers[msg.sender].tokensEarned = 0;
        payable(msg.sender).transfer(amount);

        emit TokensClaimed(msg.sender, amount);
    }

    function fundContract() external payable onlyOwner {}

    function withdrawFunds(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        payable(owner).transfer(amount);
    }

    receive() external payable {}
}
