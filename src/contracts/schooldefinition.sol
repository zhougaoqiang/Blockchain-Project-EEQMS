//SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;

enum ECertificateCategory 
{
    Diploma, 
    Poly,
    Bachelor,
    Master,
    Doctor,
    Language,
    Technical,
    Professional,
    Others
}

enum EHonor
{
    None,
    FirstClass,
    SecondUpper,
    SecondLower,
    Third,
    Others
}

enum EStudyStatus
{
    InProgress,
    Graduate,
    Others
}

struct School_Info
{
    address schoolContractAddress;
    string id;
    string name;
    string add; //schoolAddress
    string email;
    ECertificateCategory[] allowedCategory;
}

struct Student_Info
{
    address studentAdd;
    uint256 id; //provided by school
    string nationality;
    string nric;
    string passport;
    string name;
    string add; //address
}

struct Certificate_Info
{
    School_Info schoolInfo;
    ECertificateCategory category;
    EHonor honor;
    EStudyStatus status;
    string major; //Msc Of IS
    string description;
    uint256 certificateId;
    uint admissionTimestamp;
    uint graduationTimestamp;
    Student_Info studentDetails;
    uint256 signature;
}

struct Course_Info
{
    string id;
    string name;
    string professor;
    string result;
    string grade;
}

struct Transcript_Info
{
    Certificate_Info certificate;
    Course_Info[] courseList;
    uint256 signature;
}