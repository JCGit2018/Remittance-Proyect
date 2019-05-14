/*Alice creates a Remittance contract with Ether in it and a puzzle.
Alice sends a one-time-password to Bob; over SMS, say.
Alice sends another one-time-password to Carol; over email, say.
Bob treks to Carol's shop.
Bob gives Carol his one-time-password.
Carol submits both passwords to Alice's remittance contract.
Only when both passwords are correct does the contract yield the Ether to Carol.
Carol gives the local currency to Bob.
Bob leaves.
Alice is notified that the transaction went through.*/

pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Pausable.sol";
  
  
  contract Remittance is Pausable{
      
    struct Remittances {
        address exchanger;
        address thesender; 
        uint    thelimit;
        bool    withdraw; //True of false if the funds have been withdrawn by Carol or Alice after timelimit
    }
    
    mapping(bytes32 => Remittances) public remittances; 
      
      
      bytes32 keyHash;
      uint blockExpiration;
      
      //event logs
      event LogRemitSend(address sender, address exchanger, uint limit, bytes32 hashOfBoth);
      event LogWithdrawal(address sender, address receiver, uint amount);
      event LogTimeUpWithdraw(address sender, uint amount);
      
      mapping(address => uint) public balances; 
      
      
      
      
    constructor() public{
        //keyHash = ;
       blockExpiration = block.number + (7 * 86400 / 15);
      }
      
    function sendRemittance(bytes32 hashOfBoth, uint limit, address exchanger)
    public
    payable
    returns (bool success)
    {
    require(msg.value != 0);
    //Limit must be less than one week. 
    require(limit <= 604800);
    remittances[hashOfBoth].exchanger = exchanger;
    remittances[hashOfBoth].thelimit = limit + block.timestamp; 
    remittances[hashOfBoth].thesender = msg.sender;
    remittances[hashOfBoth].withdraw = false;
    //Send owner of contract a cut 
    balances[getOwner()] += msg.value/20; 
    balances[exchanger] += msg.value-(msg.value/20);
    
    emit LogRemitSend(msg.sender, exchanger, limit, hashOfBoth);
    return true;
    }
      
    /*  function sendPassword(address receiver) public returns (bytes32 password){
     //  bytes32 thePassword ="123456";      
      // return thePassword;   
      }

      function receivePassword(address sender) public returns (bool success){
       return true;   
      }*/
      
    //  function withdrawal (uint pwsswordBob, uint passwordCarol)public payable{
          /*Carol submits both passwords to Alice's remittance contract.
         Only when both passwords are correct does the contract yield the Ether to Carol.
         Carol gives the local currency to Bob.
         Bob leaves.
         Alice is notified that the transaction went through*/
     /*   require(keccak256(abi.encodePacked(pwsswordBob, passwordCarol)) == keyHash, "Access denied"); 
        require(block.number < blockExpiration);
        msg.sender.transfer(address(this).balance);
        emit LogWithdrawal(msg.sender, address(this).balance);
      }*/
      
    function exchangerWithdrawl(bytes32 pwsswordBob, bytes32  passwordCarol)
    public
    returns (bool success)
    {
    //bytes32 completepass = keccak256(hashone, hashtwo);
    bytes32 completepass = keccak256(abi.encodePacked(pwsswordBob, passwordCarol));
    address exchanger = remittances[completepass].exchanger; 
    /* Require that only the allotted exchanger can access. This checks that this exchanger is 
    allotted to this 'hash'or this remittance case. */
    require(msg.sender == exchanger);
    //require(isStillGoing(completepass) == true);
    require(block.number < blockExpiration);
    require(balances[msg.sender] > 0);
    require(remittances[completepass].withdraw == false);
    uint tosend = balances[msg.sender];
    balances[msg.sender] = 0;
    remittances[completepass].withdraw = true; 
    msg.sender.transfer(tosend);
    emit LogWithdrawal(remittances[completepass].thesender, exchanger, tosend);   
    return true;
   }
    
    /* If Carol fails to withdrawl funds before the timeline ends, 
Alice needs to be able retrieve funds. This function allows Alice to withdrawl funds after the deadline.*/
    function timeLimitUp(bytes32 hashOfBoth)
    public
    returns (bool success)
    {
   // require(isStillGoing(hashOfBoth) == false);
    require(block.number >= blockExpiration);
    require(remittances[hashOfBoth].thesender == msg.sender);
    require(remittances[hashOfBoth].withdraw == false);
    /* Allowing Alice  to withdraw the amount that she allotted to Carol. */
    uint tosend = balances[remittances[hashOfBoth].exchanger];
    balances[remittances[hashOfBoth].exchanger] = 0; 
    remittances[hashOfBoth].withdraw = true; 
    msg.sender.transfer(tosend);
    emit LogTimeUpWithdraw(msg.sender, tosend);
    return true;
   }  
      
      
 }