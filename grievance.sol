// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
 contract grievance{
    uint ffff;
     struct Form{
         string name;
         string customerId;
         string title;
         string description;
         string emailId;
     }
     Form public form;

     function write(string memory __name, string memory _customerId, string memory _title, string memory _description, string memory _emailId) 
     public{
         form=Form(__name,_customerId,_title,_description,_emailId);
     }
 }