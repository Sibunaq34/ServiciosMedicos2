<?php

declare(strict_types=1);

namespace App\Config;

final class WebService
{
    public const LOGIN = 'http://localhost:54784/ServicioLogIn.svc?wsdl';
    public const USUARIOS = 'http://localhost:54784/ServicioUsuarios.svc?wsdl';
    public const EMPLEADOS = 'http://localhost:54784/ServicioEmpleados.svc?wsdl';
    public const DETALLE_OFERENTE = 'http://localhost:54784/ServicioDetalleOferente.svc?wsdl';
    public const PUESTOS_WSDL = 'http://localhost:54784/ServicioPuestos.svc?wsdl';
    public const OFERENTES = 'http://localhost:54784/ServicioOferentesPuesto.svc?wsdl';
}


