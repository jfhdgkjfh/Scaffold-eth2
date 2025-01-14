import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const contractArguments = [deployer];

  const deployment = await deploy("YourContract", {
    from: deployer,
    args: contractArguments,
    log: true,
    autoMine: true,
  });

  const YourContract = await hre.ethers.getContract<Contract>("YourContract", deployer);

  try {
    console.log("рџ‘‹ Initial greeting:", await YourContract.greeting());
  } catch (error) {
    console.error("Error during interaction with the deployed contract:", error);
  }

  console.log(`Contract "YourContract" deployed at address: ${deployment.address}`);
};

export default deployYourContract;

deployYourContract.tags = ["YourContract"];
