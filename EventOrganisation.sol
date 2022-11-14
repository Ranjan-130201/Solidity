//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract EventContract{
    struct Event{
        address organizer;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }
    mapping(uint=>Event) public events;
    mapping(address=>mapping(uint=>uint)) public tickets;
    uint public nextId;
    
    function createEvent(string memory name, uint date,uint price,uint ticketCount) public  returns (string memory,uint,uint,uint) {
        require(date>block.timestamp,"Create a event for the future date");
        require(ticketCount>0,"Tickets available should be greater than 0");
        events[nextId]=Event(msg.sender,name,date,price,ticketCount,ticketCount);
        nextId++;
        return (name,date,price,ticketCount);
    }
    modifier check(uint id){
        require(events[id].date!=0, "Event does not exist");
        require(block.timestamp<events[id].date, "Event is finished");
        _;
    }
    function buyTicket(uint id,uint quantity) public payable check(id) {
        Event storage _event = events[id];
        require(msg.value == (_event.price*quantity), "Ethers transfered not enough");
        require(_event.ticketRemain>=quantity, "Not enough tickets");
        _event.ticketRemain-= quantity;
        tickets[msg.sender][id]+= quantity;
    }

    function transferTickets(uint id, uint quantity, address to)external check(id){
       require(tickets[msg.sender][id]>=quantity, "you do not have enough tickets");
       tickets[msg.sender][id]-=quantity;
       tickets[to][id]+=quantity;
    }
}