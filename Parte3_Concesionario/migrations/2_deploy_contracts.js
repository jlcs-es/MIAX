const EuroTokenizado = artifacts.require("EuroTokenizado");
const RegistroTrafico = artifacts.require("RegistroTrafico");
const Concesionario = artifacts.require("Concesionario");

module.exports = async (deployer, network, accounts) => {
  const euro = accounts[0];
  const trafico = accounts[1];
  const concesionario = accounts[2];


  await deployer.deploy(EuroTokenizado, {
    from: euro
  });
  await deployer.deploy(RegistroTrafico, {
    from: trafico
  });
  await deployer.deploy(Concesionario, EuroTokenizado.address, RegistroTrafico.address, {
    from: concesionario
  });
};
