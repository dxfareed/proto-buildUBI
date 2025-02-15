// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardEligTest is Test {
    RewardElig public rewardElig;
    ERC20 public mockBuild;

    address public admin;
    address public user1;
    address public user2;

    uint256 constant POOL_AMOUNT = 10**7;
    uint256 constant MAGIC_NUM = 10**18;
    uint256 constant DURATION_PERIOD = 5 minutes;

    function setUp() public {
        admin = makeAddr("admin");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        mockBuild = new ERC20("Mock BUILD", "MOCK");

        rewardElig = new RewardElig(address(mockBuild));
        vm.prank(admin);
        rewardElig.AddEligibleUser(user1);
        rewardElig.AddEligibleUser(user2);

    }

    function testAddEligibleUser() public {
        vm.prank(admin);
        rewardElig.AddEligibleUser(makeAddr("newUser"));
        assertEq(rewardElig.lis().length, 3);
    }

    function testAddDuplicateUser() public {
        vm.prank(admin);
        vm.expectRevert(stdError.revert_msg);
        rewardElig.AddEligibleUser(user1);
    }

    function testAddMultipleEligibleUsers() public {
        address[] memory users = new address[](2);
        users[0] = makeAddr("user3");
        users[1] = makeAddr("user4");

        vm.prank(admin);
        rewardElig.AddMultipleEliglibleUser(users);
        assertEq(rewardElig.lis().length, 4);
    }

    function testRemoveEligibleUser() public {
        vm.prank(admin);
        rewardElig.RemoveEligibleUser(user1);
        assertEq(rewardElig.lis().length, 1);
    }

    function testClaimReward() public {
        vm.prank(admin);
        mockBuild.transfer(address(rewardElig), POOL_AMOUNT * MAGIC_NUM); // Fund the contract

        vm.warp(block.timestamp + DURATION_PERIOD); // Advance time to make reward claimable
        vm.prank(user1);
        rewardElig.ClaimReward();

        assertGt(mockBuild.balanceOf(user1), 0); // User should have received rewards
    }

    function testClaimRewardIneligible() public {
        vm.prank(makeAddr("ineligible"));
        vm.expectRevert("Not an eligible user!");
        rewardElig.ClaimReward();
    }


    function testClaimRewardTwice() public {
        vm.prank(admin);
        mockBuild.transfer(address(rewardElig), POOL_AMOUNT * MAGIC_NUM);

        vm.warp(block.timestamp + DURATION_PERIOD);
        vm.prank(user1);
        rewardElig.ClaimReward();

        vm.warp(block.timestamp + DURATION_PERIOD * 2); // Advance time to next period
        vm.prank(user1);
        rewardElig.ClaimReward();
    }

    function testDepositBuild() public {
        uint256 amount = 100;
        vm.prank(user1);
        mockBuild.transfer(user1, amount * MAGIC_NUM);
        vm.prank(user1);

        IERC20(address(mockBuild)).approve(address(rewardElig), amount * MAGIC_NUM);
        rewardElig.DepositBuild(amount);

        assertEq(IERC20(address(mockBuild)).balanceOf(address(rewardElig)), amount * MAGIC_NUM);
    }

    function testChangeAdmin() public {
        address newAdmin = makeAddr("newAdmin");
        vm.prank(admin);
        rewardElig.ChangeAdmin(newAdmin);
        assertEq(rewardElig.CurrentAdmin(), newAdmin);
    }

    function testChangeAdminNotAdmin() public {
        vm.prank(user1);
        vm.expectRevert("only admin can invoke this function");
        rewardElig.ChangeAdmin(makeAddr("newAdmin"));
    }

    function testReadOnlyBalance4Dev() public {
        uint256 amount = 100;
        vm.prank(user1);
        mockBuild.transfer(user1, amount * MAGIC_NUM);
        vm.prank(user1);

        IERC20(address(mockBuild)).approve(address(rewardElig), amount * MAGIC_NUM);
        rewardElig.DepositBuild(amount);

        assertEq(rewardElig.ReadOnlyBalance4Dev(), amount);
    }

}