const contract = artifacts.require("Government");

module.exports = async function (deployer, network, accounts) {
  console.log("Deploying contracts...");

  // 打印正在使用的部署账户
  const deployingAccount = accounts[0];
  console.log(`Deploying account: ${deployingAccount}`);

  // 获取并打印账户余额
  const balance = await web3.eth.getBalance(deployingAccount);
  console.log(`Account balance: ${web3.utils.fromWei(balance, 'ether')} ETH`);

  // 部署迁移合约
  // const officeAdd = "0x96cdF2B017786a14A87f04953A3efB56C7c58b65";
  // const companySource = "0x6E90a0E04036499673Dd1a9D847C55E169046d68";
  // const schoolSource = "0x6E90a0E04036499673Dd1a9D847C55E169046d68";
  // const personSource = "0x6E90a0E04036499673Dd1a9D847C55E169046d68";
  // const eToken = "0x66f0642293a7aFa22843801a0D52C82b3065a903";
  await deployer.deploy(contract);
};