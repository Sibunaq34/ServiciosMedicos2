<?php

declare(strict_types=1);

namespace App\Core;

use SoapClient;
use SoapFault;
use RuntimeException;

final class SoapService
{
    private SoapClient $cliente;

    public function __construct(string $wsdl)
    {
        if (!class_exists(SoapClient::class)) {
            throw new RuntimeException('La extensión SOAP de PHP no está habilitada.');
        }

        $this->cliente = new SoapClient($wsdl, [
            'trace' => true,
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
