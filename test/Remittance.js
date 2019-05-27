const Remittance = artifacts.require("./Remittance.sol");

const { BN, sha3, toWei } = web3.utils;

contract('Remittance', function(accounts){

// const pass1 = web3.utils.asciiToHex("password1"), pass2 = web3.utils.asciiToHex("password2"), pass3 = web3.utils.asciiToHex("password3");
  let remittance ; //Instance of contract deployed
  let owner = accounts[0]; //Me or deployer
  let alice = accounts[1]; //Alice
  let carol = accounts[2]; //Carol
  
  let pass1 = 'Here is a random string!';
  let pass2 = 'Here is another random string!';

  let pass1Hashed = web3.utils.sha3(pass1);
  let pass2Hashed = web3.utils.sha3(pass2);
    
   /* Steps to take before each test run, deploy contract each time to start
  at same base case. */
  beforeEach(async function(){
    remittance = await Remittance.new(); 
  });

describe("Ownership", async function() {
    it("Should be owned by Deployer.", async function(){
      let remittanceowner = await remittance.getOwner({from:owner});
      assert.strictEqual(remittanceowner, owner, "Contract not owned by Deployer.");
    })
  })

  describe("Sending Ether to contract", async function() {
    it("Should allow individuals to send ether with secrets hashed an a limit", async function() {
      let bothHashed = web3.utils.sha3(pass1Hashed, pass2Hashed);
      let result = await remittance.sendRemittance(bothHashed, 1000, carol, {from:alice, value: 100});
      let carolsbal = await remittance.balances(carol); 
      let tx = result.logs[0];
      assert.equal(carolsbal.toString(10), 95, "Carol's balance correctly allotted.");
      assert.strictEqual(tx.args.sender, alice, "Sender recorded correctly.");
      assert.strictEqual(tx.args.exchanger, carol, "Exchanger recorded correctly.");
      assert.equal(tx.args.limit, 1000, "Limit recorded correctly.");
      assert.strictEqual(tx.args.hashOfBoth, bothHashed, "Password recorded correctly.")
    })
  })

  describe("Exchanger withdrawing Ether", async function() {
    it("Should allow exchanger to withdraw allotted funds within time limit", async function() {
      let bothHashed = await remittance.giveMyHash(pass1Hashed, pass2Hashed);
      let result = await remittance.sendRemittance(bothHashed, 100000, carol, {from:alice, value: 100});
      let nextresult = await remittance.exchangerWithdrawl(pass1Hashed, pass2Hashed, {from: carol, gas: 3000000});
      let carolsbal = await remittance.balances(carol);
      let tx = nextresult.logs[0];
      assert.equal(carolsbal.toString(10), 0, "Carol's balance incorrect, not withdrawn correctly.");
      assert.strictEqual(tx.args.sender, alice, "Sender is incorrect.");
      assert.strictEqual(tx.args.exchanger, carol, "Exchanger is incorrect");
      assert.equal(tx.args.amount.toString(10), 95, "Carol withdrew the incorrect amount.")
    })
  })

 //Contract should record when the time limit is done. 
  describe("Time limit for withdraw", async function() {
    it("Should record when the time limit has passed and let Alice withdraw", async function() {
      let bothHashed = await remittance.giveMyHash(pass1Hashed, pass2Hashed);
      let result = await remittance.sendRemittance(bothHashed, 0, carol, {from:alice, value: 100});
      let anotherresult = await remittance.cancelRemittance(bothHashed, {from:alice});
      let tx = anotherresult.logs[0];
      assert.strictEqual(tx.args.sender, alice, "Sender is not correct.");
      assert.equal(tx.args.amount, 95, "Amount refunded is not correct.")
    })
  })

   describe("Illegals Actions", async function() {
     it("should fail because alice can't cancel remittance,limit has not reached ", async function () {
       try {
             let bothHashed = await remittance.giveMyHash(pass1Hashed, pass2Hashed);
             let result = await remittance.sendRemittance(bothHashed, 10000, carol, {from:alice, value: 100});
             let anotherresult = await remittance.cancelRemittance(bothHashed, {from:alice});
       } catch (e) {
         return true;
       }
       throw new Error("can't cancel remittance,limit has not reached")
      })

     it("should fail because alice can't send a zero value remittance  ", async function () {
       try {
             let bothHashed = await remittance.giveMyHash(pass1Hashed, pass2Hashed);
             let result = await remittance.sendRemittance(bothHashed, 10000, carol, {from:alice, value: 0});
       } catch (e) {
         return true;
       }
       throw new Error("can't send a zero value remittance")
      })

     it("should fail because alice can't withdraw his own remittance before the time limit  ", async function () {
       try {
             let bothHashed = await remittance.giveMyHash(pass1Hashed, pass2Hashed);
             let result = await remittance.sendRemittance(bothHashed, 10000, carol, {from:alice, value: 0});
             let nextresult = await remittance.exchangerWithdrawl(pass1Hashed, pass2Hashed, {from: alice, gas: 3000000});
       } catch (e) {
         return true;
       }
       throw new Error("can't withdraw his own remittance before the time limit")
      })


  })

})
