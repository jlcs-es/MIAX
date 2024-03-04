import Web3 from "web3";
import bancoArtifact from "../../build/contracts/EuroTokenizado.json";
import registroTraficoArtifact from "../../build/contracts/RegistroTrafico.json";
import concesionarioArtifact from "../../build/contracts/Concesionario.json";
import vehiculoMetadataArtifact from "../../build/contracts/VehiculoMetadata.json";

const App = {
  web3: null,
  account: null,
  meta: null,
  banco: null,
  trafico: null,
  misVehiculos: [],
  concesionario: null,

  start: async function () {
    const {
      web3
    } = this;

    try {
      // get contract instance
      const networkId = await web3.eth.net.getId();
      this.banco = new web3.eth.Contract(
        bancoArtifact.abi,
        bancoArtifact.networks[networkId].address,
      );
      this.trafico = new web3.eth.Contract(
        registroTraficoArtifact.abi,
        registroTraficoArtifact.networks[networkId].address,
      );
      this.concesionario = new web3.eth.Contract(
        concesionarioArtifact.abi,
        concesionarioArtifact.networks[networkId].address,
      );

      // get accounts
      const accounts = await web3.eth.getAccounts();
      this.account = accounts[0];

      await this.actualizarCuenta();
      await this.updateBancoAdmin();
      await this.bancoObtenerSaldo();
      await this.updateTraficoAdmin();
      await this.traficoObtenerVehiculos();
      await this.concesionarioObtenerAnunciosActivos();

      document.getElementsByClassName("banco-contract-address")[0].innerHTML = this.banco._address;
      document.getElementsByClassName("trafico-contract-address")[0].innerHTML = this.trafico._address;
      document.getElementsByClassName("concesionario-contract-address")[0].innerHTML = this.concesionario._address;

      window.ethereum.on('accountsChanged', function (accounts) {
        location.reload();
      })

    } catch (error) {
      console.error("Could not connect to contract or chain.");
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
    // ghost truck husband dwarf sick bracket first enact script urban strong cement
    switch (this.account) {
      case '0x0293277eF9b9522Df577c5C97E8239414Ba027B5':
        role.innerHTML = "Admin Banco";
        break;
      case '0x8B1E6E14C4c1CaBFB96748e60CEE3Bb8D22b2891':
        role.innerHTML = "Admin Registro Tráfico";
        break;
      case '0xefcE8030F98449eA9856f5D85797Cfd08e65Fc70':
        role.innerHTML = "Admin Concesionario";
        break;
      case '0xF87523A07Fc6d01dcE61349303641de156d39bf7':
        role.innerHTML = "Usuario Vendedor";
        break;
      case '0xE9936ABF6C969EDd8774a2Ce0Cc8873E3caAEdCD':
        role.innerHTML = "Usuario Comprador";
        break;
    }
  },
  isBancoAdmin: async function () {
    const {
      owner
    } = this.banco.methods;
    const addrOwner = await owner().call();
    const isOwner = addrOwner === this.account;
    return isOwner;
  },
  updateBancoAdmin: async function () {
    const isOwner = await this.isBancoAdmin();
    if (!isOwner) {
      const bancoAdmin = document.getElementById("banco-admin");
      bancoAdmin.style.display = "none";
    }
  },
  bancoObtenerSaldo: async function () {
    const {
      balanceOf,
      totalSupply
    } = this.banco.methods;
    const balanceUser = await balanceOf(this.account).call();
    const balanceTotal = await totalSupply().call();

    const balanceUserElement = document.getElementsByClassName("banco-balance-user")[0];
    balanceUserElement.innerHTML = balanceUser;

    const balanceTotalElement = document.getElementsByClassName("banco-balance-total")[0];
    balanceTotalElement.innerHTML = balanceTotal;
  },
  bancoDeposito: async function () {
    const cantidad = parseInt(document.getElementById("banco-deposito-cantidad").value);
    const destinatario = document.getElementById("banco-deposito-destinatario").value;

    this.setStatus("Iniciando transacción...(espere)");

    const {
      acunyar
    } = this.banco.methods;
    await acunyar(destinatario, cantidad).send({
      from: this.account
    });

    this.setStatus("Transacción completada");
    this.bancoObtenerSaldo();
  },
  bancoRetirada: async function () {
    const cantidad = parseInt(document.getElementById("banco-retirada-cantidad").value);
    const destinatario = document.getElementById("banco-retirada-destinatario").value;

    this.setStatus("Iniciando transacción...(espere)");

    const {
      destruir
    } = this.banco.methods;
    await destruir(destinatario, cantidad).send({
      from: this.account
    });

    this.setStatus("Transacción completada");
    this.bancoObtenerSaldo();
  },
  isTraficAdmin: async function () {
    const {
      owner
    } = this.trafico.methods;
    const addrOwner = await owner().call();
    const isOwner = addrOwner === this.account;
    return isOwner;
  },
  updateTraficoAdmin: async function () {
    const isOwner = await this.isTraficAdmin();
    if (!isOwner) {
      const traficoAdmin = document.getElementById("trafico-admin");
      traficoAdmin.style.display = "none";
    }
  },
  traficoObtenerVehiculos: async function () {
    const {
      web3
    } = this;

    const {
      getListaVehiculosPropietario,
      getListaVehiculos
    } = this.trafico.methods;
    this.misVehiculos = await getListaVehiculosPropietario(this.account).call();
    let text = '<ul>';
    for (let i = 0; i < this.misVehiculos.length; i++) {
      const vehiculo = await this.getVehiculoMetadataByAddress(this.misVehiculos[i]);
      text += '<li>' + web3.utils.hexToUtf8(vehiculo.matricula_) + '</li>';
    }
    text += '</ul>'
    if (this.misVehiculos.length === 0) text = 'No tiene vehículos registrados a su nombre';
    const vehiculosElement = document.getElementsByClassName("trafico-vehiculos-user")[0];
    vehiculosElement.innerHTML = text;

    const isOwner = await this.isTraficAdmin();
    if (isOwner) {
      const todosVehiculos = await getListaVehiculos().call();
      let text = '';
      for (let i = 0; i < todosVehiculos.vehiculos_.length; i++) {
        const vehiculo = await this.getVehiculoMetadataByAddress(todosVehiculos.vehiculos_[i]);
        text += '<li>Matrícula: ' + web3.utils.hexToUtf8(vehiculo.matricula_) + ', Propietario: ' + todosVehiculos.propietarios_[i] + '</li>';
      }
      if (todosVehiculos.length === 0) text = 'No hay vehículos registrados';
      const todosVehiculosElement = document.getElementsByClassName("trafico-vehiculos-admin")[0];
      todosVehiculosElement.innerHTML = text;
    }
  },
  traficoRegistroNuevoVehiculo: async function () {
    const {
      web3
    } = this;

    const numPuertas = parseInt(document.getElementById("trafico-registro-puertas").value);
    const esGasolina = document.getElementById("trafico-registro-gasolina").value == 'true';
    const tipo = parseInt(document.getElementById("trafico-registro-tipo").value);
    const modelo = document.getElementById("trafico-registro-modelo").value;
    const matricula = web3.utils.utf8ToHex(document.getElementById("trafico-registro-matricula").value);

    this.setStatus("Iniciando transacción...(espere)");
    const {
      registrarNuevoVehiculo
    } = this.trafico.methods;
    const propietario = document.getElementById("trafico-registro-propietario").value;
    await registrarNuevoVehiculo(propietario, numPuertas, esGasolina, matricula, tipo, modelo).send({
      from: this.account
    })
    this.setStatus("Transacción completada");
    this.traficoObtenerVehiculos();
  },
  getVehiculoMetadataByAddress: async function (address) {
    const {
      web3
    } = this;
    const contract = new web3.eth.Contract(
      vehiculoMetadataArtifact.abi,
      address,
    );
    const {
      getInfo
    } = contract.methods;
    const info = await getInfo().call();
    return info;
  },
  concesionarioObtenerAnunciosActivos: async function () {
    const {
      web3
    } = this;
    const {
      getListaVehiculosConAnuncio,
      getAnuncio
    } = this.concesionario.methods;
    let anuncios = await getListaVehiculosConAnuncio().call();
    anuncios = anuncios.filter(function (item, pos, self) {
      return self.indexOf(item) == pos;
    })
    let text = '';
    let count = 0;
    for (let i = 0; i < anuncios.length; i++) {
      const anuncio = await getAnuncio(anuncios[i]).call();
      if (anuncio.existe_) {
        text += '<br>' + 'Id: ' + anuncio.id_ + ', Matricula: ' + web3.utils.hexToUtf8(anuncio.matricula_) + ', Precio (en céntimos): ' + anuncio.precioVenta_.valueOf();
        if (anuncio.propietario_ === this.account)
          text += '<a style="margin-left: 15px" href="javascript:App.concesionarioEliminarAnuncioVehiculo(\'' + anuncio.matricula_ + '\')">Eliminar</a>';
        else
          text += '<a style="margin-left: 15px" href="javascript:App.concesionarioComprarAnuncioVehiculo(\'' + anuncio.matricula_ + '\',' + anuncio.precioVenta_ + ')">Comprar</a>';
        count++;
      }
    }
    if (count === 0) text = 'No hay anuncios de venta activos';
    const anunciosElement = document.getElementsByClassName("concesionario-anuncios")[0];
    anunciosElement.innerHTML = text;
  },
  concesionarioPublicarAnuncioVehiculo: async function () {
    const {
      web3
    } = this;
    const precio = parseInt(document.getElementById("concesionario-publicar-precio").value);
    const matricula = web3.utils.utf8ToHex(document.getElementById("concesionario-publicar-matricula").value);

    this.setStatus("Iniciando transacción...(espere)");
    const {
      approve
    } = this.trafico.methods;
    await approve(this.concesionario._address, matricula).send({
      from: this.account
    })
    const {
      publicarAnuncioVenta
    } = this.concesionario.methods;
    await publicarAnuncioVenta(matricula, precio).send({
      from: this.account
    })
    this.setStatus("Transacción completada");
    await this.concesionarioObtenerAnunciosActivos();
  },
  concesionarioComprarAnuncioVehiculo: async function (matricula, precio) {
    this.setStatus("Iniciando transacción...(espere)");
    const {
      approve
    } = this.banco.methods;
    await approve(this.concesionario._address, precio).send({
      from: this.account
    })
    const {
      comprarAnuncio
    } = this.concesionario.methods;
    await comprarAnuncio(matricula).send({
      from: this.account
    })
    this.setStatus("Transacción completada");
    await this.bancoObtenerSaldo();
    await this.traficoObtenerVehiculos();
    await this.concesionarioObtenerAnunciosActivos();
  },
  concesionarioEliminarAnuncioVehiculo: async function (matricula, precio) {
    this.setStatus("Iniciando transacción...(espere)");
    const {
      cancelarAnuncioVenta
    } = this.concesionario.methods;
    await cancelarAnuncioVenta(matricula).send({
      from: this.account
    })
    this.setStatus("Transacción completada");
    await this.concesionarioObtenerAnunciosActivos();
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