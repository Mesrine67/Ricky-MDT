const app = new Vue({
    el: '#app',
    data: {
        nomeRisorsa : GetParentResourceName(),
        schermata : 'login',
        optionSelected : 'home',

        searchByName : '',
        searchByPlate : '',

        accessReport : false,
        
        viewingOtherReport : false,

        allReports : [],

        officerNumber : 0,


        config : false,

        blockUpdateNote : false,

        statusFedinaPenale : 'closed',

        aggiungendoReato : false,

        idReato : 0,

        personeRicercate : 0,

        sureView : false,


        officerInfo : {
            name : '',
            grade : {
                name : 'officer',
                number : 0,
                label : 'Officer',
            },
            id: 5
        },

        playerSelezionato : {
            job : {
                name : '',
                label : '',
                grade : {
                    name : '',
                    number : 0,
                    label : '',
                }
            },
            veicoli : [],
            case : [],
        },

        veicoli : [
            {
                plate : 'ABCD123',
                owner : 'Alessandro Elso',
                identifier : 'char1:1',

            }
        ],

        cittadini : [
            {
                firstName : 'Alessandro',
                lastName : 'Elso',
                dateOfBirth : '12/12/1999',
                wanted : false,
                identifier : 'char1:1',
                contoBancario: 122,
                note : "è un ",
                job : {
                    name : 'police',
                    label : 'Police',
                    grade : {
                        name : 'officer',
                        number : 0,
                        label : 'Officer',
                    },
                }
            },
            {
                firstName : 'Luca',
                lastName : 'Alaski',
                dateOfBirth : '12/12/1999',
                wanted : true,
                identifier : 'char1:2',
                note : '',
                contoBancario : 0,
                job : {
                    name : 'police',
                    label : 'Police',
                    grade : {
                        name : 'officer',
                        number : 0,
                        label : 'Officer',
                    },
                }
            }
        ]
    },
    methods : {


        animationStart() {
            $(".leftBar").fadeOut(5)                    
            if(this.config.AnimazioneIniziale) {
                    var nome = this.officerInfo.name 
                    for(let i = 0; i < nome.length; i++) {
                        setTimeout(() => {
                            $(".usernameInput").val($(".usernameInput").val() + nome.charAt(i))
                        }, i*100);
                    }
                    setTimeout(() => {
                        for(let i = 0; i < 7; i++) {
                            setTimeout(() => {
                                $(".passwordInput").val($(".passwordInput").val() + i)
                            }, i*100);
                        }
                    }, 1200);

                    setTimeout(() => {
                        setTimeout(() => {
                            $(".leftBar").fadeIn(500)                    
                        }, 0);
                        $(".schermataHome").fadeIn(500)
                        this.schermata = 'home'  
                    }, 2100);      
            } else {
                setTimeout(() => {
                    $(".leftBar").fadeIn(500)                    
                }, 0);
                $(".schermataHome").fadeIn(500)
                this.schermata = 'home'   
            }
        },

        updateOptionSelected(option) {
            this.optionSelected = option
            var opzioni = document.getElementsByClassName('opzione')

            for(let i = 0; i < opzioni.length; i++) {
                var coso = opzioni[i]
                coso.style.borderBottom = "0.0926vh solid #464646"
            }

            for(let i = 0; i < opzioni.length; i++) {
                var coso = opzioni[i]
                if(coso.getAttribute('opzione') == option) {
                    coso.style.borderBottom = "0.0926vh solid white"
                }
            }
        },

        home() {
            this.schermata = 'home'
            this.updateOptionSelected('home')
        },

        databaseCittadini() {
            this.schermata = 'databaseCittadini'
            this.updateOptionSelected('databaseCittadini')
        },

        databaseVeicoli() {
            this.schermata = 'databaseVeicoli'
            this.updateOptionSelected('databaseVeicoli')
        },

        getCittadiniFromInput() {
            if(this.searchByName == '') {
                return this.cittadini
            } else {
                var cittadini = []
                for(let i = 0; i < this.cittadini.length; i++) {
                    var cittadino = this.cittadini[i]
                    if(cittadino.firstName.toLowerCase().includes(this.searchByName.toLowerCase()) || cittadino.lastName.toLowerCase().includes(this.searchByName.toLowerCase()) || cittadino.fullName.toLowerCase().includes(this.searchByName.toLowerCase())) {
                        cittadini.push(cittadino)
                    }
                }
                return cittadini
            }
        },

        getVeicoliFromInput() {
            if(this.searchByPlate == '') {
                return this.veicoli
            } else {
                var veicoli = []
                for(let i = 0; i < this.veicoli.length; i++) {
                    var veicolo = this.veicoli[i]
                    if(veicolo.plate.toLowerCase().includes(this.searchByPlate.toLowerCase()) || veicolo.owner.toLowerCase().includes(this.searchByPlate.toLowerCase())) {
                        veicoli.push(veicolo)
                    }
                }
                return veicoli
            }
        },

        loadPhoto()  {
            var logo = this.playerSelezionato.photo
            return {
                backgroundImage: `url(${logo})`,
            }
        },

        infoPeople(identifier, veicoli) {
            // $(".note").val('')
            for(const[k,v] of Object.entries(this.cittadini)) {
                if(v.identifier == identifier) {
                    this.playerSelezionato = v
                    // this.playerSelezionato.job = JSON.parse(this.playerSelezionato.job)
                    // console.log(JSON.stringify(this.playerSelezionato))
                }
            }


            if (this.playerSelezionato.note.length == 0) {
                $(".note").val('')
            } else {
                $(".note").val(this.playerSelezionato.note)
            }
            if(veicoli) {
                this.schermata = 'infoVehicle'
            } else {
                this.schermata = 'infoPeople'
            }

            var note = document.getElementsByClassName('note')[0]
            note.addEventListener("change", function() {
                if(this.blockUpdateNote) {
                    return
                }
                app.postMessage('updateNote', {
                    identifier : app.playerSelezionato.identifier,
                    note : note.value
                })
                this.blockUpdateNote = true
                setTimeout(() => {
                    this.blockUpdateNote = false
                }, 1000)
        });
        },

        updateOfficerInfo(officerInfo) {
            this.officerInfo = officerInfo
        },

        updateCittadini(cittadini) {
            this.cittadini = cittadini

            if(this.playerSelezionato!=false) {
                for(const[k,v] of Object.entries(this.cittadini)) {
                    if(v.identifier == this.playerSelezionato.identifier) {
                        this.playerSelezionato = v
                    }
                }
            }

            this.personeRicercate = this.cittadini.filter(cittadino => cittadino.wanted == true).length
        },

        postMessage(name, data) {
            $.post(`https://${this.nomeRisorsa}/${name}`, JSON.stringify(data))
        },

        addWanted() {

            $(".wanted").fadeOut(200)
            setTimeout(() => {
                $(".wanted").fadeIn(200)
            }, 500);

            $(".addwanted").fadeOut(200)
            setTimeout(() => {
                $(".removeWanted").fadeIn(200)                
            }, 500);
            var identifier = this.playerSelezionato.identifier
            this.postMessage('addWanted', {
                identifier : identifier
            })
        },

        removeWanted() {

            $(".wanted").fadeOut(200)
            setTimeout(() => {
                $(".wanted").fadeIn(200)
            }, 500);

            $(".removeWanted").fadeOut(200)
            setTimeout(() => {
                $(".addWanted").fadeIn(200)
            }, 500);
            var identifier = this.playerSelezionato.identifier
            this.postMessage('removeWanted', {
                identifier : identifier
            })
        },

        maiuscFirstLetter(string) {
            return string.charAt(0).toUpperCase() + string.slice(1);
        },

        updateVeicoli(veicoli) {
            this.veicoli = veicoli
        },

        updateConfig(config) {
            this.config = config
            this.config.Translate = this.config.Translate[config.Language]
        },

        setGps(x,y,z) {
            $("#app").fadeOut(500)
            this.postMessage('setGps', {
                x : x,
                y : y,
                z : z
            })
        },
        
        fedinaPenale() {
            $(".containerFedinaPenale").show()
            this.statusFedinaPenale = 'opened'
        },

        closeFedina() {
            var element = document.getElementsByClassName('background')[0]
            element.classList.add('containerPenale1')
                setTimeout(() => {
                    var container = document.getElementsByClassName('containerFedinaPenale')[0]
                    container.style.display = 'none'
                    element.classList.remove("containerPenale1")
                }, 1000);
                this.statusFedinaPenale = false
        },

        addFedina() {
            $(".addPenale").show()
            this.aggiungendoReato = true
        },


        closeAddFedina() {
            var element = document.getElementsByClassName('addPenale')[0]
            element.classList.add('containerPenale1')
                setTimeout(() => {
                    element.style.display = "none"
                    element.classList.remove("containerPenale1")
                }, 1000);
                this.aggiungendoReato = false
        },

        deleteFedina(id) {
            this.idReato = id
            this.aggiungendoReato = true
            $(".sure").show()
            this.sureView = true
        },

        closeSure() {
            var element = document.getElementsByClassName('sure')[0]
            element.classList.add('containerPenale1')
                setTimeout(() => {
                    element.style.display = "none"
                    element.classList.remove("containerPenale1")
            }, 1000);
            this.sureView = false
            this.aggiungendoReato = false
        },

        confirmSure() {
            this.closeSure()
            var idReato = this.idReato
            this.postMessage('deleteReato', {
                identifier : this.playerSelezionato.identifier,
                idReato : idReato
            })
            this.sureView = false
        },

        addReato() {
            var reason = $(".penaleReason").val()
            this.postMessage('addReato', {
                identifier : this.playerSelezionato.identifier,
                reason : reason
            })
            this.closeAddFedina()
            $(".penaleReason").val('')
        },

        updateOfficerJob(job) {
            this.officerInfo.job = job
            document.getElementsByClassName('nomeUtente')[0].innerHTML = this.officerInfo.name + ' - ' + this.officerInfo.job.grade.label
        },

        rapporti() {
            this.schermata = 'rapporti'
            this.updateOptionSelected('rapporti')
        },

        listarapporti() {
            this.schermata = 'listarapporti'
            this.updateOptionSelected('listarapporti')
        },

        addReport() {
            this.schermata = 'creaRapporto'
        },

        closeCreateReport() {
            this.schermata = 'rapporti'
        },

        creaReport() {
            var text = $(".textaddreport").val()
            this.postMessage('createReport', {
                rapporto : text
            })
            this.closeCreateReport()
        },

        viewReport(msg, bool) {
            this.schermata = 'viewReport'
            if(bool) {
                this.viewingOtherReport = true
            }
            setTimeout(() => {
                $(".viewReport").html(msg)            
            }, 1);
        },

        closeViewReport() {
            if(this.viewingOtherReport) {
                this.schermata = 'listarapporti'
            } else {
                this.schermata = 'rapporti'
            }
            this.viewingOtherReport = false
        },

        setAccessReport(bool) {
            this.accessReport = bool
        },


        updateOfficerNumber(number) {
            this.officerNumber = number
        }
    }
});

document.onkeyup = function (data) {
    // console.log(app.schermata, app.statusFedinaPenale, app.aggiungendoReato, app.sureView)
    if(data.key == 'Escape' && app.schermata == 'infoPeople' && app.statusFedinaPenale == 'opened' && app.aggiungendoReato == false && app.sureView == false) {
        app.closeFedina()
        app.statusFedinaPenale = 'closed'
    } else if(data.key == 'Escape' && app.schermata == 'infoPeople' && app.statusFedinaPenale == 'opened' && app.aggiungendoReato == true && app.sureView == false) {
        app.closeAddFedina()
        app.aggiungendoReato = false
    } else if(data.key == 'Escape' && app.schermata == 'infoPeople' && app.statusFedinaPenale == 'opened' && app.aggiungendoReato == true && app.sureView == true) {
        app.closeSure()
        app.sureView = false
    } else if (data.key == 'Escape' && app.schermata == 'infoPeople') {
        app.schermata = 'databaseCittadini'
    } else if (data.key == 'Escape' && app.schermata == 'infoVehicle') {
        app.schermata = 'databaseVeicoli'
    } else if(data.key == 'Escape' && app.schermata == 'home') {
        $("#app").fadeOut(500)
        app.postMessage('close')
    }else if(data.key == 'Escape' && app.schermata == 'databaseCittadini') {
        $("#app").fadeOut(500)
        app.postMessage('close')
    } else if(data.key == 'Escape' && app.schermata == 'databaseVeicoli') {
        $("#app").fadeOut(500)
        app.postMessage('close')
    } else if(data.key == 'Escape' && app.schermata == 'rapporti') {
        $("#app").fadeOut(500)
        app.postMessage('close')
    } else if(data.key == 'Escape' && app.schermata == 'creaRapporto') {
        app.closeCreateReport()
    } else if(data.key == 'Escape' && app.schermata == 'viewReport') {
        app.closeViewReport()
    }
};


window.addEventListener('message', function(event) {
    var data = event.data;
    if (data.type === "OPEN_MDT") {
        app.schermata = 'login'
        app.statusFedinaPenale = false
        app.aggiungendoReato = false
        app.sureView = false
        app.updateOptionSelected('home')
        $(".infoPeople").fadeOut(500)
        $(".informations").fadeOut(500)
        $("#app").show()
        app.updateOfficerInfo(data.officerInfo)
        app.updateCittadini(data.cittadini)
        app.updateVeicoli(data.veicoli)
        app.animationStart()
    } else if(data.type == "UPDATE_CITTADINI") {
        app.updateCittadini(data.cittadini)
    } else if(data.type == "UPDATE_CONFIG") {
        app.updateConfig(data.config)
    } else if(data.type == "UPDATE_OFFICER_JOB") {
        app.updateOfficerJob(data.job)
    } else if(data.type == "UPDATE_OFFICER_INFO") {
        app.updateOfficerInfo(data.officerInfo)
    } else if(data.type == "UPDATE_VEICOLI") {
        app.updateVeicoli(data.veicoli)
    } else if(data.type === "ACCESS_LIST_REPORT") {
        app.setAccessReport(true)
        app.allReports = data.reports
    } else if(data.type === "UPDATE_OFFICER_NUMBER") {
        app.updateOfficerNumber(data.officerNumber)
    }
})


