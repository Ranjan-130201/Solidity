// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding{
    mapping (address=>uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmt;
    uint public noOfContributers;

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool complete;
        uint noOfVoters;
        mapping (address=>bool)voters;
    }

    mapping (uint=>Request) public requests;
    uint public numRequest;

    constructor (uint _target, uint _deadline){
        target= _target;
        deadline= block.timestamp + _deadline;
        minimumContribution= 100 wei;
        manager= msg.sender;
    }

    function sendEth() public payable {
        require(block.timestamp< deadline,"Deadline has passed");
        require(msg.value>=minimumContribution,"minimum contribution is 100 wei");

        if(contributors[msg.sender]==0){
            noOfContributers++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmt+=msg.value;
    }
    function getBalance() public view returns (uint){
        return address(this).balance;
    }
    function refund() public{
        require(block.timestamp>deadline && raisedAmt<target);
        require(contributors[msg.sender]>0);
        address payable user= payable (msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }
    modifier onlyManager(){
        require(msg.sender == manager,"Only Manager has access");
        _;
    }
    function createRequest( string memory _description, address payable _recipient, uint _value ) public onlyManager{
        Request storage newRequest= requests[numRequest];
        numRequest++;
        newRequest.description= _description;
        newRequest.recipient  = payable (_recipient);
        newRequest.value= _value; 
        newRequest.complete= false;
        newRequest.noOfVoters= 0;
    }
    function voteRequest(uint _requestNo) public {
        require(contributors[msg.sender]>0,"You Must be a contriubuter");
        Request storage thisRequest= requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;
    }
    function makePayment(uint _requestNo) public payable onlyManager {
        require(raisedAmt>=target);
        Request storage thisRequest= requests[_requestNo];
        require(thisRequest.complete==false,"Request completed");
        require(thisRequest.noOfVoters> noOfContributers/2,"Majority doesnot support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.complete=true;
    }
}