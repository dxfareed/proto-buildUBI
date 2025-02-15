// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IWETH9 {
    function deposit() external payable;
    function withdraw(uint256) external;
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256); // Add balanceOf
}

contract AutoSwapDonationTest is Test {
    AutoSwapDonation public autoSwap;
    ERC20 public mockToken;
    ISwapRouter public mockSwapRouter;
    IWETH9 public weth;

    address public user;
    address public owner;

    uint24 public constant FEE = 300;


    function setUp() public {
        user = makeAddr("user");
        owner = makeAddr("owner");

        mockToken = new ERC20("Mock Token", "MOCK");
        mockSwapRouter = new MockSwapRouter();
        weth = IWETH9(0x4200000000000000000000000000000000000006);


        autoSwap = new AutoSwapDonation(address(mockToken), address(mockSwapRouter), FEE);
        autoSwap.transferOwnership(owner);
    }

    function testDonate() public payable {
        uint256 initialBalance = mockToken.balanceOf(user);
        uint256 ethAmount = 1 ether;

        vm.prank(user);
        autoSwap.donate{value: ethAmount}();

        assertEq(mockToken.balanceOf(user), initialBalance + _calculateSwapOutput(ethAmount), "Incorrect token balance after donation");
        assertEq(address(this).balance, 0, "ETH balance should be zero");
    }

    function testDonateZeroETH() public payable {
        vm.prank(user);
        vm.expectRevert("Must send ETH");
        autoSwap.donate{value: 0}();
    }

    function testWithdraw() public {
        uint256 ethAmount = 1 ether;
        vm.prank(user);
        autoSwap.donate{value: ethAmount}();

        vm.prank(owner);
        uint256 withdrawAmount = mockToken.balanceOf(user);
        autoSwap.withdraw(address(mockToken), withdrawAmount);
        assertEq(mockToken.balanceOf(user), 0);
    }

    function testWithdrawNotOwner() public {
        uint256 ethAmount = 1 ether;
        vm.prank(user);
        autoSwap.donate{value: ethAmount}();

        vm.prank(user);
        vm.expectRevert();
        autoSwap.withdraw(address(mockToken), 1);
    }

    function testSetSwapFee() public {
        vm.prank(owner);
        autoSwap.setSwapFee(5000);
        assertEq(autoSwap.swapFee(), 5000);
    }

    function testSetSwapFeeNotOwner() public {
        vm.prank(user);
        vm.expectRevert();
        autoSwap.setSwapFee(5000);
    }

    contract MockSwapRouter is ISwapRouter {
        function exactInputSingle(ExactInputSingleParams memory params)
            public
            payable
            returns (uint256 amountOut)
        {
            if (params.tokenIn == 0x4200000000000000000000000000000000000006) { // WETH
                amountOut = params.amountIn * 1000; // Example conversion rate
            } else {
                revert("Unsupported swap");
            }
        }
    }

    function _calculateSwapOutput(uint256 amountIn) internal pure returns (uint256) {
        return amountIn * 1000;
    }

}