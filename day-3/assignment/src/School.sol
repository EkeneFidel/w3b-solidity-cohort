// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract School {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner allowed");
        _;
    }

    struct Student {
        uint256 id;
        string name;
        uint256 level;
        bool feesPaid;
        uint256 amountPaid;
        uint256 paidAt;
    }

    uint256 public studentCount;
    mapping(uint256 => Student) public students;

    mapping(uint256 => uint256) public levelFee;

    struct Staff {
        uint256 id;
        string name;
        string role;
        address payable wallet;
        uint256 salary;
        uint256 lastPaidAt;
    }

    uint256 public staffCount;
    mapping(uint256 => Staff) public staffs;

    function setSchoolFees() external onlyOwner {
        levelFee[100] = 0.01 ether;
        levelFee[200] = 0.02 ether;
        levelFee[300] = 0.03 ether;
        levelFee[400] = 0.04 ether;
    }

    function registerStudent(
        string calldata name,
        uint256 level
    ) external payable {
        require(levelFee[level] > 0, "Invalid level");
        require(msg.value == levelFee[level], "Incorrect fee");

        studentCount++;

        students[studentCount] = Student({
            id: studentCount,
            name: name,
            level: level,
            feesPaid: true,
            amountPaid: msg.value,
            paidAt: block.timestamp
        });
    }

    function registerStaff(
        string calldata name,
        string calldata role,
        address payable wallet,
        uint256 salary
    ) external onlyOwner {
        staffCount++;

        staffs[staffCount] = Staff({
            id: staffCount,
            name: name,
            role: role,
            wallet: wallet,
            salary: salary,
            lastPaidAt: 0
        });
    }

    function payStaff(uint256 staffId) external onlyOwner {
        Staff storage staff = staffs[staffId];

        require(staff.wallet != address(0), "Staff not found");
        require(address(this).balance >= staff.salary, "Not enough balance");

        (bool success, ) = staff.wallet.call{value: staff.salary}("");
        require(success, "Salary payment failed");

        staff.lastPaidAt = block.timestamp;
    }

    function getStudent(
        uint256 studentId
    ) external view returns (Student memory) {
        return students[studentId];
    }

    function getStaff(uint256 staffId) external view returns (Staff memory) {
        return staffs[staffId];
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
