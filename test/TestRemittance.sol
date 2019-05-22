pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Remittance.sol";

contract TestRemittance {

    uint public initialBalance = 100 finney;

    function testCanDeposit() public {
        Remittance remit = new Remittance();

        bytes32 hash = keccak256(abi.encodePacked(uint(0)));
        remit.sendRemittance.value(1 finney)(hash, 1,address(1));
        address alice;
        address carol;
        uint limit;
        bool withdraw;
        (carol,alice,limit, withdraw) = remit.remittances(hash);

        Assert.equal(carol, address(1), "Carol should be me");
        Assert.equal(withdraw, false, "No withdraw made");
        Assert.equal(limit, block.timestamp + 1, "Should have recorded the last block");
    }




}
