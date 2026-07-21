<?php
if (!defined('ABSPATH')) {
    exit;
}

$aut3_id_formulario = 'aut3-' . wp_unique_id();
?>

<section class="aut3-registro-oferente" data-aut3-registro-oferente data-url-retorno="<?php echo esc_url($aut3_url_retorno); ?>">
    <div class="aut3-card">
        <?php
        // Persona C - Kenneth
        // Formulario visual de AUT3.
        ?>
        <form class="aut3-form" novalidate enctype="multipart/form-data" data-aut3-form>
            <?php
            // Persona C - Kenneth
            // Envia el registro al endpoint publico de AUT3.
            ?>
            <input type="hidden" name="action" value="aut3_registrar_oferente">
            <input type="hidden" name="nonce" value="<?php echo esc_attr(wp_create_nonce('aut3_registro_oferente')); ?>">

            <div class="aut3-field aut3-field-full">
                <label for="<?php echo esc_attr($aut3_id_formulario); ?>-puesto">Puesto seleccionado</label>
                <input
                    id="<?php echo esc_attr($aut3_id_formulario); ?>-puesto"
                    type="text"
                    value="<?php echo esc_attr($aut3_datos_puesto['nombre']); ?>"
                    readonly
                    aria-readonly="true"
                >
                <input type="hidden" name="codigo_puesto" value="<?php echo esc_attr($aut3_datos_puesto['codigo']); ?>">
                <p class="aut3-error" data-error-for="codigo_puesto" aria-live="polite"></p>
            </div>

            <div class="aut3-field">
                <label for="<?php echo esc_attr($aut3_id_formulario); ?>-identificacion">Identificaci&oacute;n</label>
                <input id="<?php echo esc_attr($aut3_id_formulario); ?>-identificacion" name="identificacion" type="text" autocomplete="off" maxlength="30" required aria-describedby="<?php echo esc_attr($aut3_id_formulario); ?>-error-identificacion">
                <p id="<?php echo esc_attr($aut3_id_formulario); ?>-error-identificacion" class="aut3-error" data-error-for="identificacion" aria-live="polite"></p>
            </div>

            <div class="aut3-field">
                <label for="<?php echo esc_attr($aut3_id_formulario); ?>-tipo-identificacion">Tipo de identificaci&oacute;n</label>
                <select id="<?php echo esc_attr($aut3_id_formulario); ?>-tipo-identificacion" name="tipo_identificacion" required aria-describedby="<?php echo esc_attr($aut3_id_formulario); ?>-error-tipo-identificacion">
                    <option value="">Seleccione</option>
                    <option value="CedulaIdentidad">C&eacute;dula de identidad</option>
                    <option value="DIMEX">DIMEX</option>
                    <option value="Pasaporte">Pasaporte</option>
                </select>
                <p id="<?php echo esc_attr($aut3_id_formulario); ?>-error-tipo-identificacion" class="aut3-error" data-error-for="tipo_identificacion" aria-live="polite"></p>
            </div>

            <div class="aut3-field aut3-field-full">
                <label for="<?php echo esc_attr($aut3_id_formulario); ?>-nombre-completo">Nombre completo</label>
                <input id="<?php echo esc_attr($aut3_id_formulario); ?>-nombre-completo" name="nombre_completo" type="text" autocomplete="name" maxlength="150" required aria-describedby="<?php echo esc_attr($aut3_id_formulario); ?>-error-nombre-completo">
                <p id="<?php echo esc_attr($aut3_id_formulario); ?>-error-nombre-completo" class="aut3-error" data-error-for="nombre_completo" aria-live="polite"></p>
            </div>

            <div class="aut3-field">
                <label for="<?php echo esc_attr($aut3_id_formulario); ?>-fecha-nacimiento">Fecha de nacimiento</label>
                <input id="<?php echo esc_attr($aut3_id_formulario); ?>-fecha-nacimiento" name="fecha_nacimiento" type="date" required aria-describedby="<?php echo esc_attr($aut3_id_formulario); ?>-error-fecha-nacimiento">
                <p id="<?php echo esc_attr($aut3_id_formulario); ?>-error-fecha-nacimiento" class="aut3-error" data-error-for="fecha_nacimiento" aria-live="polite"></p>
            </div>

            <div class="aut3-field">
                <label for="<?php echo esc_attr($aut3_id_formulario); ?>-correos">Correo o correos</label>
                <textarea id="<?php echo esc_attr($aut3_id_formulario); ?>-correos" name="correos" rows="3" inputmode="email" aria-describedby="<?php echo esc_attr($aut3_id_formulario); ?>-help-correos <?php echo esc_attr($aut3_id_formulario); ?>-error-correos"></textarea>
                <p id="<?php echo esc_attr($aut3_id_formulario); ?>-help-correos" class="aut3-help">Separe varios correos con comas.</p>
                <p id="<?php echo esc_attr($aut3_id_formulario); ?>-error-correos" class="aut3-error" data-error-for="correos" aria-live="polite"></p>
            </div>

            <div class="aut3-field">
                <label for="<?php echo esc_attr($aut3_id_formulario); ?>-telefonos">Tel&eacute;fono o tel&eacute;fonos</label>
                <textarea id="<?php echo esc_attr($aut3_id_formulario); ?>-telefonos" name="telefonos" rows="3" inputmode="tel" required aria-describedby="<?php echo esc_attr($aut3_id_formulario); ?>-help-telefonos <?php echo esc_attr($aut3_id_formulario); ?>-error-telefonos"></textarea>
                <p id="<?php echo esc_attr($aut3_id_formulario); ?>-help-telefonos" class="aut3-help">Separe varios tel&eacute;fonos con comas.</p>
                <p id="<?php echo esc_attr($aut3_id_formulario); ?>-error-telefonos" class="aut3-error" data-error-for="telefonos" aria-live="polite"></p>
            </div>

            <div class="aut3-field">
                <label for="<?php echo esc_attr($aut3_id_formulario); ?>-curriculum">Archivo de curr&iacute;culum</label>
                <input id="<?php echo esc_attr($aut3_id_formulario); ?>-curriculum" name="curriculum" type="file" required aria-describedby="<?php echo esc_attr($aut3_id_formulario); ?>-help-curriculum <?php echo esc_attr($aut3_id_formulario); ?>-error-curriculum">
                <p id="<?php echo esc_attr($aut3_id_formulario); ?>-help-curriculum" class="aut3-help">Adjunte el curr&iacute;culum.</p>
                <p id="<?php echo esc_attr($aut3_id_formulario); ?>-error-curriculum" class="aut3-error" data-error-for="curriculum" aria-live="polite"></p>
            </div>

            <div class="aut3-actions">
                <p class="aut3-server-message" data-aut3-server-message aria-live="polite"></p>
                <button type="submit" class="aut3-button aut3-button-primary">Aceptar</button>
                <button type="button" class="aut3-button aut3-button-secondary" data-aut3-cancelar>Cancelar</button>
            </div>
        </form>
    </div>

    <?php
    // Persona C - Kenneth
    // Modal de confirmacion tras persistencia exitosa.
    ?>
    <div class="aut3-modal" data-aut3-modal hidden>
        <div class="aut3-modal-backdrop"></div>
        <div class="aut3-modal-dialog" role="dialog" aria-modal="true" aria-labelledby="<?php echo esc_attr($aut3_id_formulario); ?>-modal-title">
            <p id="<?php echo esc_attr($aut3_id_formulario); ?>-modal-title" data-aut3-modal-mensaje>Datos guardados de manera satisfactoria</p>
            <button type="button" class="aut3-button aut3-button-primary" data-aut3-modal-aceptar>Aceptar</button>
        </div>
    </div>
</section>
