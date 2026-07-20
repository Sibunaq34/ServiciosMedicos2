<?php

declare(strict_types=1);

namespace App\Core;

use SoapClient;
use SoapFault;

final class ServicioSoap
{
    private SoapClient $cliente;

    public function __construct(string $wsdl)
    {
        $this->cliente = new SoapClient($wsdl, [
            'trace' => false,
            'exceptions' => true,
            'cache_wsdl' => WSDL_CACHE_NONE,
            'connection_timeout' => 10,
        ]);
    }

    /**
     * @throws SoapFault
     */
    public function call(string $metodo, array $parametros = []): mixed
    {
        return $this->cliente->__soapCall($metodo, [$parametros]);
    }
}
