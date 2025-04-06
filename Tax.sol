// SPDX-License-Identifier: MIT

//Contract address: 0xBBf94EC94c748f997F2f6E6cf114Caa052184DEB

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

    function calcTax(address user) public view returns (uint256) {

        uint256 _income = income[user];

        //According to the Income tax table of 2023
        if (_income <= 250000){ 
            return 0;
        }else if(_income > 250000 && _income <= 400000){
            return ((_income - 250000) * 15) / 100;
        }else if(_income > 400000 && _income <= 800000){
            return ((_income - 400000) * 20) / 100 + 22500;   
        }else if(_income > 800000 && _income<= 2000000){
            return ((_income - 800000) * 25) / 100 + 102500;   
        }else if(income[user] > 2000000 && _income <= 8000000){
            return ((_income - 2000000) * 30) / 100 + 402500;   
        }else if(income[user] > 8000000){
            return ((_income - 5000000) * 35) / 100 + 2202500;   
        }

    }

    function payTax() public payable {
        uint256 taxAmount = calcTax(msg.sender);
        require(msg.value <= taxAmount, "Insufficient tax payment");
        taxPaid[msg.sender] += taxAmount;
        emit taxFiled(msg.sender, taxAmount); //Is connected with event initialization
    }

    function audit_User(address user) public view onlyGovernment returns (uint256, uint256) {
        return (income[user], taxPaid[user]);
    }
}
