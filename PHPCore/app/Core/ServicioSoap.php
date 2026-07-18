<?php

declare(strict_types=1);

namespace App\Core;

use App\Config\WebService;
use SoapClient;
use SoapFault;

final class SoapService
{
    private SoapClient $cliente;

    public function __construct(string $wsdl)
    {
        $this->cliente = new SoapClient($wsdl, [
            'trace' => true,
            'exceptions' => true,
        ]);
    }

    public function call(string $metodo, array $parametros = []): mixed
    {
        return $this->cliente->__soapCall($metodo, [$parametros]);
    }
}