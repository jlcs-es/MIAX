const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("ConcesionarioModule", (m) => {
  const euroAdmin = m.getAccount(0);
  const traficoAdmin = m.getAccount(1);
  const concesionarioAdmin = m.getAccount(2);

  const euroContract = m.contract("EuroTokenizado", [], {
    from: euroAdmin
  });

  const traficoContract = m.contract("RegistroTrafico", [], {
    from: traficoAdmin
  });

  const concesionarioContract = m.contract("Concesionario",
    [euroContract, traficoContract],
    {
      from: concesionarioAdmin
    }
  )

  return { euroContract, traficoContract, concesionarioContract };
});
