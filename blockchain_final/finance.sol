// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract LoanContract {
    address public borrower;
    address public lender;

    uint public loanAmount;
    uint public interestRate; 
    uint public totalRepayable;
    uint public dueDate;
    uint public loanStart;
    bool public isApproved;
    bool public isRepaid;

    constructor() {
        lender = msg.sender; 
    }

    modifier onlyBorrower() {
        require(msg.sender == borrower, "Only borrower can call this");
        _;
    }

    modifier onlyLender() {
        require(msg.sender == lender, "Only lender can call this");
        _;
    }

    function requestLoan(uint _amount, uint _interestRate, uint _repayDurationInDays) external {
        require(borrower == address(0), "Loan already requested");
        borrower = msg.sender;
        loanAmount = _amount;
        interestRate = _interestRate;
        totalRepayable = loanAmount + (loanAmount * interestRate / 100);
        dueDate = block.timestamp + (_repayDurationInDays * 1 days);
    }

    function approveLoan() external payable onlyLender {
        require(!isApproved, "Loan already approved");
        require(msg.value == loanAmount, "Incorrect amount sent");

        loanStart = block.timestamp;
        isApproved = true;
        payable(borrower).transfer(loanAmount);
    }

    function repayLoan() external payable onlyBorrower {
        require(isApproved, "Loan not approved");
        require(!isRepaid, "Already repaid");
        require(block.timestamp <= dueDate, "Loan overdue");
        require(msg.value == totalRepayable, "Incorrect repayment amount");

        isRepaid = true;
        payable(lender).transfer(msg.value);
    }

    function checkStatus() public view returns (string memory) {
        if (!isApproved) return "Loan Requested";
        if (isApproved && !isRepaid && block.timestamp < dueDate) return "Loan Active";
        if (isRepaid) return "Loan Repaid";
        if (block.timestamp > dueDate && !isRepaid) return "Loan Defaulted";
        return "Unknown";
    }

    function getDetails() public view returns (
        address _borrower,
        address _lender,
        uint _loanAmount,
        uint _interestRate,
        uint _totalRepayable,
        uint _dueDate,
        bool _isApproved,
        bool _isRepaid
    ) {
        return (
            borrower,
            lender,
            loanAmount,
            interestRate,
            totalRepayable,
            dueDate,
            isApproved,
            isRepaid
        );
    }
}
