<?php

class Database
{
    protected static $db;
    private function __construct()
    {
        $db_host = DB_HOST;
        $db_nome = DB_NAME;
        $db_usuario = DB_USER;
        $db_senha = DB_PASS;
        $db_driver = DB_DRIVER;

        $sistema_titulo = "Locacar - Locadora de Veículos";
        $sistema_email = "adrianoanschau@gmail.com";

        try
        {
            self::$db = new PDO("$db_driver:host=$db_host; dbname=$db_nome", $db_usuario, $db_senha);
            self::$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            //self::$db->exec('SET NAMES utf8');
            self::$db->exec('SET CLIENT_ENCODING TO \'UTF8\'');
        }
        catch (PDOException $e)
        {
            mail($sistema_email, "PDOException em $sistema_titulo", $e->getMessage());
            die("Erro de conexão: " . $e->getMessage());
        }
    }

    public static function conexao()
    {
        if (!self::$db)
        {
            new Database();
        }
        return self::$db;
    }

}