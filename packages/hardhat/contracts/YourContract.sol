//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// Useful for debugging. Remove when deploying to a live network.
import "hardhat/console.sol";

// Use openzeppelin to inherit battle-tested implementations (ERC20, ERC721, etc)
// import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * A smart contract that allows changing a state variable of the contract and tracking the changes
 * It also allows the owner to withdraw the Ether in the contract
 * @author BuidlGuidl
 */
contract YourContract {
    // State Variables
    address public immutable owner;
    string public greeting = "Building Unstoppable Apps!!!";
    bool public premium = false;
    uint256 public totalCounter = 0;
    mapping(address => uint) public userGreetingCounter;
    
    // Additions for bill payment functionality
    struct Bill {
        uint id;             // Unique ID for each bill
        address payer;       // Address of the person who needs to pay the bill
        uint amount;         // Amount due for this bill
        bool paid;           // Whether the bill has been paid
        uint timestamp;      // Timestamp of creation
    }
    
    uint private nextBillId = 1;   // Counter for generating unique IDs
    mapping(uint => Bill) private bills;  // Mapping of bill IDs to their details

    // Events: a way to emit log statements from smart contract that can be listened to by external parties
    event GreetingChange(address indexed greetingSetter, string newGreeting, bool premium, uint256 value);
    event BillCreated(uint indexed billId, address indexed payer, uint amount, uint timestamp);
    event BillPaid(uint indexed billId, address indexed payer, uint amount, uint timestamp);

    // Constructor: Called once on contract deployment
    // Check packages/hardhat/deploy/00_deploy_your_contract.ts
    constructor(address _owner) {
        owner = _owner;
    }

    // Modifier: used to define a set of rules that must be met before or after a function is executed
    // Check the withdraw() function
    modifier isOwner() {
        // msg.sender: predefined variable that represents address of the account that called the current function
        require(msg.sender == owner, "Not the Owner");
        _;
    }

    /**
     * Function that allows anyone to change the state variable "greeting" of the contract and increase the counters
     *
     * @param _newGreeting (string memory) - new greeting to save on the contract
     */
    function setGreeting(string memory _newGreeting) public payable {
        // Print data to the hardhat chain console. Remove when deploying to a live network.
        console.log("Setting new greeting '%s' from %s", _newGreeting, msg.sender);

        // Change state variables
        greeting = _newGreeting;
        totalCounter += 1;
        userGreetingCounter[msg.sender] += 1;

        // msg.value: built-in global variable that represents the amount of ether sent with the transaction
        if (msg.value > 0) {
            premium = true;
        } else {
            premium = false;
        }

        // emit: keyword used to trigger an event
        emit GreetingChange(msg.sender, _newGreeting, msg.value > 0, msg.value);
    }

    /**
     * Function that allows the owner to withdraw all the Ether in the contract
     * The function can only be called by the owner of the contract as defined by the isOwner modifier
     */
    function withdraw() public isOwner {
        (bool success, ) = owner.call{ value: address(this).balance }("");
        require(success, "Failed to send Ether");
    }

    /**
     * Function that allows the contract to receive ETH
     */
    receive() external payable {}

    // New Functions for Bill Payment

    /**
     * Create a new bill
     *
     * @param _payer (address) - Address of the person who needs to pay the bill
     * @param _amount (uint) - Amount due for this bill
     */
    function createBill(address _payer, uint _amount) public returns (uint billId) {
        require(_amount > 0, "Amount must be greater than zero.");
        
        billId = nextBillId++;
        bills[billId] = Bill(billId, _payer, _amount, false, block.timestamp);
        
        emit BillCreated(billId, _payer, _amount, block.timestamp);
        
        return billId;
    }

    /**
     * Pay a bill
     *
     * @param _billId (uint) - ID of the bill to be paid
     */
    function payBill(uint _billId) public payable {
        Bill storage bill = bills[_billId];
        require(bill.payer == msg.sender, "Only the payer can pay the bill.");
        require(!bill.paid, "The bill has already been paid.");
        require(msg.value >= bill.amount, "Insufficient funds to pay the bill.");
        
        bill.paid = true;
        
        emit BillPaid(_billId, msg.sender, bill.amount, block.timestamp);
    }

    /**
     * Get the status of a bill
     *
     * @param _billId (uint) - ID of the bill to check
     * @return (Bill) - Details of the bill
     */
    function getBillStatus(uint _billId) public view returns (Bill memory) {
        return bills[_billId];
    }
}