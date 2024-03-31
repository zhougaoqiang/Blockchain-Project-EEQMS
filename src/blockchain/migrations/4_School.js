const contract = artifacts.require("School");

module.exports = async function (deployer, network, accounts) {
  console.log("Deploying contracts...");

  // 打印正在使用的部署账户
  const deployingAccount = accounts[0];
  console.log(`Deploying account: ${deployingAccount}`);

  // 获取并打印账户余额
  const balance = await web3.eth.getBalance(deployingAccount);
  console.log(`Account balance: ${web3.utils.fromWei(balance, 'ether')} ETH`);

  // 部署迁移合约
//   const schoolInfo = {
//     schoolContractAddress: "", // 需要填写具体的地址
//     id: "school01",
//     name: "Example School",
//     add: "123 School St, City, Country",
//     email: "info@example.com"
// };
  const id = "NTU";
  const name = "Nanyang Technological University";
  const add = "50 Nanyang Ave, Singapore 639798";
  const email = "ntu@edu.sg";
  await deployer.deploy(contract, id, name, add, email);
};