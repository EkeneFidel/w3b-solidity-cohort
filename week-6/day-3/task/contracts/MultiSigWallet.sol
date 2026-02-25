// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSigWallet {
    address[] public admins;
    mapping(address => bool) public isAdmin;

    uint256 public constant REQUIRED_APPROVALS = 3;

    struct WithdrawalRequest {
        address requester;
        address to;
        uint256 amount;
        uint256 approvals;
        bool executed;
    }

    WithdrawalRequest[] public requests;
    mapping(uint256 => mapping(address => bool)) public approvedBy;

    event Deposit(address indexed sender, uint256 amount);
    event WithdrawalRequested(
        uint256 indexed id,
        address indexed requester,
        address to,
        uint256 amount
    );
    event Approved(uint256 indexed id, address indexed admin);
    event Executed(uint256 indexed id);

    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Not admin");
        _;
    }

    constructor(address[] memory _admins) {
        require(_admins.length >= REQUIRED_APPROVALS, "Need at least 3 admins");

        for (uint i = 0; i < _admins.length; i++) {
            address admin = _admins[i];
            require(!isAdmin[admin], "Duplicate admin");

            isAdmin[admin] = true;
            admins.push(admin);
        }
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function requestWithdrawal(
        address _to,
        uint256 _amount
    ) external returns (uint256 id) {
        require(_amount > 0, "Amount must be > 0");

        requests.push(
            WithdrawalRequest({
                requester: msg.sender,
                to: _to,
                amount: _amount,
                approvals: 0,
                executed: false
            })
        );

        id = requests.length - 1;

        emit WithdrawalRequested(id, msg.sender, _to, _amount);
    }

    function approve(uint256 id) external onlyAdmin {
        WithdrawalRequest storage req = requests[id];

        require(!req.executed, "Already executed");
        require(!approvedBy[id][msg.sender], "Already approved");

        approvedBy[id][msg.sender] = true;
        req.approvals++;

        emit Approved(id, msg.sender);
    }

    function execute(uint256 id) external {
        WithdrawalRequest storage req = requests[id];

        require(!req.executed, "Already executed");
        require(req.approvals >= REQUIRED_APPROVALS, "Not enough approvals");
        require(address(this).balance >= req.amount, "Insufficient balance");

        req.executed = true;

        (bool sent, ) = payable(req.to).call{value: req.amount}("");
        require(sent, "Transfer failed");

        emit Executed(id);
    }

    function getRequestsCount() external view returns (uint256) {
        return requests.length;
    }
}
