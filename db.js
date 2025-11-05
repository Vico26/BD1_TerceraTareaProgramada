const sql=require('mssql');
const config={
    user:'sa',
    password:'aWo3lp0lloC1x',
    server:'DESKTOP-VICTORI',
    database:'Empresa3',
    options:{
        encrypt:true,
        trustServerCertificate:true
    }
};
module.exports={sql,config};