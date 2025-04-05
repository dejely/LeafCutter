// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract taxCompliance {
    
    address public government;
    mapping(address => uint256) public income; //Dictionary in python (This is just key-value pairs in another syntax)
    mapping(address => uint256) public taxPaid;

    //Initializing event (possibly for user notification)
    event taxFiled(address indexed user, uint256 taxAmount);
    
    modifier onlyGovernment() {
        require(msg.sender == government, "Not authorized");
        _;
    }
    //This will be read first:
    constructor() {
        government = msg.sender;
    }

    function reportIncome(uint256 amount) public {
        income[msg.sender] += amount;
    }

    function calcTax(address user, uint256 rate) public view returns (uint256) {
        //According to the Income tax table of 2023
        if (income[user] <= 250000){ 
            return (income[user]);
        }else if(income[user] > 250000 && income[user] <= 400000){
            return ((income[user] - 250000) * 15) / 100;
        }else if(income[user] > 400000 && income[user] <= 800000){
            return ((income[user] - 400000) * 20) / 100 + 22500;   
        }else if(income[user] > 800000 && income[user] <= 2000000){
            return ((income[user] - 800000) * 25) / 100 + 102500;   
        }else if(income[user] > 2000000 && income[user] <= 8000000){
            return ((income[user] - 2000000) * 30) / 100 + 402500;   
        }else if(income[user] > 8000000){
            return ((income[user] - 5000000) * 35) / 100 + 2202500;   
        }

        return (income[user] * rate) / 100; //arg rate needs to be const instead of relying on user input
    }

    function payTax(uint256 rate) public payable {
        uint256 taxAmount = calcTax(msg.sender, rate);
        require(msg.value <= taxAmount, "Insufficient tax payment");
        taxPaid[msg.sender] += taxAmount;
        emit taxFiled(msg.sender, taxAmount); //Is connected with event initialization
    }

    function audit_User(address user) public view onlyGovernment returns (uint256, uint256) {
        return (income[user], taxPaid[user]);
    }
}
