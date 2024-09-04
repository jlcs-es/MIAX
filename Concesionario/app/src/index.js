import Web3 from "web3";
import bancoArtifact from "../../artifacts/contracts/EuroTokenizado.sol/EuroTokenizado.json";

import deployedAddresses from "../../ignition/deployments/chain-31337/deployed_addresses.json";

const App = {
  web3: null,
  account: null,
  banco: null,

  start: async function () {
    const {
      web3
    } = this;

    try {
      // get contract instance
      this.banco = new web3.eth.Contract(
        bancoArtifact.abi,
        deployedAddresses["ConcesionarioModule#EuroTokenizado"],
      );

      // get accounts
      const accounts = await web3.eth.getAccounts();
      this.account = accounts[0];

      await this.actualizarCuenta();
      await this.updateBancoAdmin();
      await this.bancoObtenerSaldo();

      document.getElementsByClassName("banco-contract-address")[0].innerHTML = this.banco._address;

      window.ethereum.on('accountsChanged', function (accounts) {
        location.reload();
      })

    } catch (error) {
      console.error("Could not connect to contract or chain.", error);
    }
  },
  setStatus: function (message) {
    const status = document.getElementById("status");
    status.innerHTML = message;
  },
  actualizarCuenta: async function () {
    const cuenta = document.getElementsByClassName("cuenta")[0];
    cuenta.innerHTML = this.account;

    const role = document.getElementsByClassName("role")[0];
    // test test test test test test test test test test test junk
    switch (this.account) {
      case '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266':
        role.innerHTML = "Admin Banco";
        break;
      case '0x70997970C51812dc3A010C7d01b50e0d17dc79C8':
        role.innerHTML = "Admin Registro Tráfico";
        break;
      case '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC':
        role.innerHTML = "Admin Concesionario";
        break;
      case '0x90F79bf6EB2c4f870365E785982E1f101E93b906':
        role.innerHTML = "Usuario Vendedor";
        break;
      case '0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65':
        role.innerHTML = "Usuario Comprador";
        break;
    }
  },
  isBancoAdmin: async function () {
    // TODO
  },
  updateBancoAdmin: async function () {
    // TODO
  },
  bancoObtenerSaldo: async function () {
    // TODO
  },
  bancoDeposito: async function () {
    // TODO
  },
  bancoRetirada: async function () {
    // TODO
  }
};

window.App = App;

window.addEventListener("load", function () {
  if (window.ethereum) {
    // use MetaMask's provider
    App.web3 = new Web3(window.ethereum);
    window.ethereum.enable(); // get permission to access accounts
  } else {
    console.warn(
      "No web3 detected. Falling back to http://127.0.0.1:7545. You should remove this fallback when you deploy live",
    );
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    App.web3 = new Web3(
      new Web3.providers.HttpProvider("http://127.0.0.1:8545"),
    );
  }

  App.start();
});