// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/MarketToken.sol";
import "../src/StakingMarket.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract MarketStakingTest is Test {
    MarketToken token;
    MarketStaking staking;

    string name_ = "Market Token";
    string symbol_ = "MKT";

    address owner_ = vm.addr(1);
    address user = vm.addr(2);

     uint256 stakingPeriod_ = 1000;
    uint256 fixedStakeAmount_ = 10 ether;
    uint256 rewardPerPeriod_ = 1 ether;

    function setUp() external {
        vm.prank(owner_);
        token = new MarketToken(name_, symbol_, owner_);

        staking = new MarketStaking(
            address(token),
            owner_,
            stakingPeriod_,
            fixedStakeAmount_,
            rewardPerPeriod_
        );

        // give user tokens
        vm.prank(owner_);
        token.mint(user, 1_000_000 ether);
    }

    function testTokenDeployed() external view {
        assert(address(token) != address(0));
    }

    function testStakingDeployed() external view {
        assert(address(staking) != address(0));
    }

    function testChangePeriodRevertsIfNotOwner() external {
        vm.expectRevert();
        staking.changeStakingPeriod(1);
    }

    function testChangePeriodWorks() external {
        vm.startPrank(owner_);
        uint256 before_ = staking.stakingPeriod();
        staking.changeStakingPeriod(1);
        uint256 after_ = staking.stakingPeriod();
        assertTrue(before_ != 1);
        assertEq(after_, 1);
        vm.stopPrank();
    }

    function testContractReceivesEtherCorrectly() external {
        vm.startPrank(owner_);
        vm.deal(owner_, 1 ether);

        uint256 beforeBal = address(staking).balance;
        (bool ok, ) = address(staking).call{value: 1}("");
        require(ok, "fund failed");
        uint256 afterBal = address(staking).balance;

        assertEq(afterBal - beforeBal, 1);
        vm.stopPrank();
    }

    function testDepositRevertsIncorrectAmount() external {
        vm.startPrank(user);
        IERC20(address(token)).approve(address(staking), 1 ether);

        vm.expectRevert(bytes("16"));
        staking.deposit(1 ether);
        vm.stopPrank();
    }

    function testDepositWorks() external {
        vm.startPrank(user);

        uint256 amount = staking.fixedStakeAmount();
        IERC20(address(token)).approve(address(staking), amount);

        uint256 balBefore = staking.userBalance(user);
        uint256 tsBefore = staking.lastClaimAt(user);

        staking.deposit(amount);

        uint256 balAfter = staking.userBalance(user);
        uint256 tsAfter = staking.lastClaimAt(user);

        assertEq(balAfter - balBefore, amount);
        assertEq(tsBefore, 0);
        assertEq(tsAfter, block.timestamp);

        vm.stopPrank();
    }

    function testUserCannotDepositTwice() external {
        vm.startPrank(user);

        uint256 amount = staking.fixedStakeAmount();
        IERC20(address(token)).approve(address(staking), amount);
        staking.deposit(amount);

        // try deposit again
        IERC20(address(token)).approve(address(staking), amount);
        vm.expectRevert(bytes("17"));
        staking.deposit(amount);

        vm.stopPrank();
    }

    function testWithdrawZeroWithoutDepositNoRevert() external {
        vm.startPrank(user);
        uint256 beforeBal = staking.userBalance(user);
        staking.withdraw();
        uint256 afterBal = staking.userBalance(user);
        assertEq(afterBal, beforeBal);
        vm.stopPrank();
    }

    function testWithdrawWorks() external {
        vm.startPrank(user);

        uint256 amount = staking.fixedStakeAmount();
        IERC20(address(token)).approve(address(staking), amount);
        staking.deposit(amount);

        uint256 userTokenBefore = IERC20(address(token)).balanceOf(user);
        uint256 staked = staking.userBalance(user);

        staking.withdraw();

        uint256 userTokenAfter = IERC20(address(token)).balanceOf(user);

        assertEq(userTokenAfter, userTokenBefore + staked);
        vm.stopPrank();
    }

    function testClaimRevertsIfNotStaking() external {
        vm.startPrank(user);
        vm.expectRevert(bytes("18"));
        staking.claimRewards();
        vm.stopPrank();
    }

    function testClaimRevertsIfNotElapsedTime() external {
        vm.startPrank(user);

        uint256 amount = staking.fixedStakeAmount();
        IERC20(address(token)).approve(address(staking), amount);
        staking.deposit(amount);

        vm.expectRevert(bytes("19"));
        staking.claimRewards();

        vm.stopPrank();
    }

    function testClaimRevertsIfNoEthInContract() external {
        vm.startPrank(user);

        uint256 amount = staking.fixedStakeAmount();
        IERC20(address(token)).approve(address(staking), amount);
        staking.deposit(amount);

        vm.warp(block.timestamp + stakingPeriod_);

        vm.expectRevert(bytes("20"));
        staking.claimRewards();

        vm.stopPrank();
    }

    function testClaimWorks() external {
        // fund contract with ETH rewards
        vm.startPrank(owner_);
        vm.deal(owner_, 100 ether);
        (bool ok, ) = address(staking).call{value: 100 ether}("");
        require(ok, "fund failed");
        vm.stopPrank();

        // user stakes
        vm.startPrank(user);
        uint256 amount = staking.fixedStakeAmount();
        IERC20(address(token)).approve(address(staking), amount);
        staking.deposit(amount);

        vm.warp(block.timestamp + stakingPeriod_);

        uint256 beforeEth = user.balance;
        staking.claimRewards();
        uint256 afterEth = user.balance;

        assertEq(afterEth - beforeEth, rewardPerPeriod_);
        assertEq(staking.lastClaimAt(user), block.timestamp);

        vm.stopPrank();
    }
}
