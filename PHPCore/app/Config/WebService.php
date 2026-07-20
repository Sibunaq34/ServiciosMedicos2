<?php

declare(strict_types=1);

namespace App\Config;

final class WebService
{

    public const EMPLEADOS = 'http://localhost:54784/ServicioEmpleados.svc?wsdl';
    public const DETALLE_OFERENTE = 'http://localhost:54784/ServicioDetalleOferente.svc?wsdl';
    public const OFERENTES = 'http://localhost:54784/ServicioOferentesPuesto.svc?wsdl';
}


