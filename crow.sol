// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Crowdfunding {
    address public owner;
    uint256 public goalAmount; // هدف جمع‌آوری سرمایه
    uint256 public raisedAmount; // مقدار جمع‌آوری شده
    uint256 public deadline; // زمان پایان جمع‌آوری
    mapping(address => uint256) public contributions; // مشارکت‌ها

    event Funded(address indexed contributor, uint256 amount);
    event GoalReached(address indexed projectOwner, uint256 totalAmount);
    event Refund(address indexed contributor, uint256 amount);

    constructor(uint256 _goalAmount, uint256 _duration) {
        owner = msg.sender;
        goalAmount = _goalAmount;
        deadline = block.timestamp + _duration; // تعیین زمان پایان
    }

    // واریز وجه به قرارداد
    function contribute() public payable {
        require(block.timestamp < deadline, "Crowdfunding has ended");
        require(msg.value > 0, "Contribution must be greater than zero");

        contributions[msg.sender] += msg.value;
        raisedAmount += msg.value;

        emit Funded(msg.sender, msg.value);

        // اگر هدف جمع‌آوری برآورده شود
        if (raisedAmount >= goalAmount) {
            emit GoalReached(owner, raisedAmount);
        }
    }

    // درخواست بازپرداخت (اگر هدف جمع‌آوری برآورده نشود)
    function refund() public {
        require(block.timestamp >= deadline, "Crowdfunding has not ended yet");
        require(raisedAmount < goalAmount, "Goal reached, no refund available");

        uint256 contributedAmount = contributions[msg.sender];
        require(contributedAmount > 0, "No contributions to refund");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(contributedAmount);

        emit Refund(msg.sender, contributedAmount);
    }

    // برداشت وجوه توسط صاحب پروژه (اگر هدف برآورده شود)
    function withdrawFunds() public {
        require(msg.sender == owner, "Only the owner can withdraw funds");
        require(raisedAmount >= goalAmount, "Goal not reached");
        require(block.timestamp >= deadline, "Crowdfunding has not ended yet");

        uint256 amount = raisedAmount;
        raisedAmount = 0;
        payable(owner).transfer(amount);
    }

    // مشاهده وضعیت جمع‌آوری سرمایه
    function getStatus() public view returns (uint256, uint256, uint256) {
        return (raisedAmount, goalAmount, deadline);
    }
}