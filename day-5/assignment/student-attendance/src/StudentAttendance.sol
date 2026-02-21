// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./IERC20.sol";

contract SchoolManagement {
    IERC20 public token;
    address public owner;

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    struct Student {
        string name;
        uint256 age;
        uint256 level;
        bool present;
        bool feesPaid;
        uint256 paymentTime;
    }

    Student[] public students;

    mapping(uint256 => uint256) public levelFee;

    event StudentAdded(uint256 id, string name, uint256 level);
    event AttendanceUpdated(uint256 id, bool present);
    event StudentRemoved(uint256 id);

    function setFee(uint256 level, uint256 fee) external onlyOwner {
        levelFee[level] = fee;
    }

    function registerStudent(
        string memory _name,
        uint256 _age,
        uint256 _level
    ) public {
        uint256 fee = levelFee[_level];
        require(fee > 0, "Fee not set");

        require(
            token.transferFrom(msg.sender, address(this), fee),
            "Payment failed"
        );

        students.push(
            Student({
                name: _name,
                age: _age,
                level: _level,
                present: false,
                feesPaid: true,
                paymentTime: block.timestamp
            })
        );

        emit StudentAdded(students.length - 1, _name, _level);
    }

    function updateAttendance(uint256 _id, bool _present) public onlyOwner {
        students[_id].present = _present;
        emit AttendanceUpdated(_id, _present);
    }

    function removeStudent(uint256 _id) public onlyOwner {
        students[_id] = students[students.length - 1];
        students.pop();
        emit StudentRemoved(_id);
    }

    function getStudents() public view returns (Student[] memory) {
        return students;
    }

    struct Staff {
        string name;
        address wallet;
        uint256 salary;
        bool suspended;
    }

    Staff[] public staffs;

    event StaffAdded(uint256 id, string name);
    event StaffSuspended(uint256 id, bool status);
    event StaffPaid(uint256 id, uint256 amount);

    function employStaff(
        string memory _name,
        address _wallet,
        uint256 _salary
    ) public onlyOwner {
        staffs.push(
            Staff({
                name: _name,
                wallet: _wallet,
                salary: _salary,
                suspended: false
            })
        );

        emit StaffAdded(staffs.length - 1, _name);
    }

    function suspendStaff(uint256 _id, bool _status) public onlyOwner {
        staffs[_id].suspended = _status;
        emit StaffSuspended(_id, _status);
    }

    function payStaff(uint256 _id) public onlyOwner {
        Staff memory s = staffs[_id];

        require(!s.suspended, "Staff suspended");

        token.transfer(s.wallet, s.salary);

        emit StaffPaid(_id, s.salary);
    }

    function getStaffs() public view returns (Staff[] memory) {
        return staffs;
    }
}
