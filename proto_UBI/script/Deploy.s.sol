// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "src/AutoSwapDonation.sol";
import "src/RewardElig.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DeployAll is Script {
    function run() public {
        vm.startBroadcast();
        ERC20 buildToken = new ERC20("BUILD Token", "BUILD");
        vm.stopBroadcast();
        console.log("BUILD Token deployed at:", address(buildToken));

        address swapRouterAddress = 0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4;
        uint24 swapFee = 3000;
        vm.startBroadcast();
        AutoSwapDonation autoSwap = new AutoSwapDonation(address(buildToken), swapRouterAddress, swapFee);
        vm.stopBroadcast();
        console.log("AutoSwapDonation deployed at:", address(autoSwap));

        vm.startBroadcast();
        RewardElig rewardElig = new RewardElig(address(buildToken));
        vm.stopBroadcast();
        console.log("RewardElig deployed at:", address(rewardElig));

        vm.startBroadcast();
        rewardElig.ChangeAdmin(msg.sender);
        vm.stopBroadcast();

        uint256 initialRewards = 10**8 * 10**18;
        vm.startBroadcast();
        buildToken.transfer(address(rewardElig), initialRewards);
        vm.stopBroadcast();
        console.log("Initial rewards transferred to RewardElig");
    }
}