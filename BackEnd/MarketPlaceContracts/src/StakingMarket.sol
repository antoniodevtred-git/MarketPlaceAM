// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract MarketStaking is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable stakingToken;

    uint256 public stakingPeriod;
    uint256 public fixedStakeAmount;
    uint256 public rewardPerPeriod; // in wei

    mapping(address => uint256) public userBalance;
    mapping(address => uint256) public lastClaimAt;

    event DepositTokens(address userAddress_, uint256 depositAmount_);
    event WithdrawTokens(address indexed user_, uint256 amoun_);
    event RewardClaimed(address indexed user_, uint256 amount_);
    event ChangeStakingPeriod(uint256 newStakingPeriod);
    event EtherFunded(uint256 amount);



    constructor(address stakingToken_,address owner_,uint256 stakingPeriod_,uint256 fixedStakeAmount_,uint256 rewardPerPeriod_) Ownable(owner_) {
        require(stakingToken_ != address(0), "22");
        require(stakingPeriod_ > 0, "23");

        stakingToken = IERC20(stakingToken_);
        stakingPeriod = stakingPeriod_;
        fixedStakeAmount = fixedStakeAmount_;
        rewardPerPeriod = rewardPerPeriod_;
    }

    // ===== Stake =====

    function deposit(uint256 amount_) external nonReentrant {
        require(amount_ == fixedStakeAmount, "01");
        require(userBalance[msg.sender] == 0, "02");

        // EFFECTS
        userBalance[msg.sender] = amount_;
        lastClaimAt[msg.sender] = block.timestamp;

        // INTERACTIONS
        stakingToken.safeTransferFrom(msg.sender, address(this), amount_);

        emit DepositTokens(msg.sender, amount_);
    }

    // ===== Withdraw =====

    function withdraw() external nonReentrant {
        uint256 balance = userBalance[msg.sender];

        // EFFECTS
        userBalance[msg.sender] = 0;

        // INTERACTIONS
        if (balance > 0) {
            stakingToken.safeTransfer(msg.sender, balance);
        }

        emit WithdrawTokens(msg.sender, balance);
    }

    // ===== Rewards =====

    function claimRewards() external nonReentrant {
        require(userBalance[msg.sender] == fixedStakeAmount, "03");

        uint256 elapsed = block.timestamp - lastClaimAt[msg.sender];
        require(elapsed >= stakingPeriod, "04");

        // EFFECTS
        lastClaimAt[msg.sender] = block.timestamp;

        require(address(this).balance >= rewardPerPeriod, "05");

        // INTERACTIONS
        (bool ok, ) = payable(msg.sender).call{value: rewardPerPeriod}("");
        require(ok, "06");

        emit RewardClaimed(msg.sender, rewardPerPeriod);
    }

    // ===== Admin =====

    function changeStakingPeriod(uint256 newStakingPeriod_) external onlyOwner {
        require(newStakingPeriod_ > 0, "08");
        stakingPeriod = newStakingPeriod_;
        emit ChangeStakingPeriod(newStakingPeriod_);
    }

    /// @notice Owner funds ETH rewards
    receive() external payable onlyOwner {
        emit EtherFunded(msg.value);
    }




}