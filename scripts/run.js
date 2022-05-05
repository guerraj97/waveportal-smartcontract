/*
* run script para el contrato de WavePortal.sol
* El proceso en general deberia ser compilar -> hacer el deploy -> ejecutar. 
* correrlo con lo siguiente comando:
- moverte a la carpeta del proyecto con cd (linux o McOs y Windows)
- correr npx hardhat run scripts/run.js  
- para el deploy usar npx hardhat run scripts/deploy.js --network rinkeby
//
*/
const main = async () => {
  const waveContractFactory = await hre.ethers.getContractFactory("WavePortal"); //esta funcion compila el contrato y crea los archivos que vamos a usar 
                                                                                //en la carpeta de artifacts.

                                                                              
/*
Genera una red local de Ethereum para correr el contrato, luego, la destruye. 
*/                                                         
  const waveContract = await waveContractFactory.deploy({
    value: hre.ethers.utils.parseEther("0.1"), 
  });
  await waveContract.deployed();//espera a que el deploy este listo

  //Nos da la direccion del contrato una vez listo. 
  console.log("Deploy contract address:", waveContract.address);

  let contractBalance = await hre.ethers.provider.getBalance( //hre es Hardhat Runtime Enviroment y es para correr los scripts. 
    waveContract.address
  );
  console.log(
    "Contract balance:",
    hre.ethers.utils.formatEther(contractBalance)
  );

  /*
   * Let's try two waves now
   */
  const waveTxn = await waveContract.wave("This is wave #1");
  await waveTxn.wait();

  const waveTxn2 = await waveContract.wave("This is wave #2");
  await waveTxn2.wait();

  contractBalance = await hre.ethers.provider.getBalance(waveContract.address);
  console.log(
    "Contract balance:",
    hre.ethers.utils.formatEther(contractBalance)
  );

  let allWaves = await waveContract.getAllWaves();
  console.log(allWaves);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();