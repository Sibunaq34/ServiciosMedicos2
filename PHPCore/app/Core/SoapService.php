<?php

declare(strict_types=1);

namespace App\Core;

use RuntimeException;
use SoapClient;
use SoapFault;

final class SoapService
{
    private SoapClient $cliente;

    public function __construct(string $wsdl)
    {
        $this->cliente = new SoapClient($wsdl, [
            'trace' => false,
            'exceptions' => true,
            'cache_wsdl' => WSDL_CACHE_NONE,
            'connection_timeout' => 10,
            'features' => SOAP_SINGLE_ELEMENT_ARRAYS,
        ]);
    }

    public function call(string $metodo, array $parametros = []): mixed
    {
        try {
            return $this->cliente->__soapCall($metodo, [$parametros]);
        } catch (SoapFault $exception) {
            error_log('SOAP: '.$exception->getMessage());
            throw new RuntimeException(
                'El servicio solicitado no está disponible.',
                0,
                $exception
            );
        }
    }
}
