<?php

declare(strict_types=1);

namespace App\Config;

final class WebService
{
    public const LOGIN = 'http://localhost:8080/ServicioLogin.svc?wsdl';
    public const USUARIO = 'http://localhost:8080/ServicioUsuario.svc?wsdl';
    public const PACIENTE = 'http://localhost:8080/ServicioPaciente.svc?wsdl';
    public const EMPLEADOS = 'http://localhost:54784/ServicioEmpleados.svc?wsdl';
    public const DETALLE_OFERENTE = 'http://localhost:54784/ServicioDetalleOferente.svc?wsdl';

    // Persona C - Kenneth
    // Centraliza el WSDL utilizado por CORE8.
    public const DETALLE_OFERENTE = 'http://localhost:54784/ServicioDetalleOferente.svc?wsdl';
    public const OFERENTES = 'http://localhost:54784/ServicioOferentesPuesto.svc?wsdl';
}


