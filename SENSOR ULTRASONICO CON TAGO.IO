import network
import urequests
import time
from machine import Pin, time_pulse_us

# =========================
# CONFIG WIFI
# =========================
ssid = "RED MECATRONICA"
password = "MECA2026@."

# =========================
# CONFIG TAGO
# =========================
url = "https://api.tago.io/data"
headers = {
    "Content-Type": "application/json",
    "Device-Token": "e8e28909-6ba4-4f64-8ce4-e301adfd7a85"
}

# =========================
# CONECTAR WIFI
# =========================
wifi = network.WLAN(network.STA_IF)
wifi.active(True)
wifi.connect(ssid, password)

print("Conectando a WiFi...")
while not wifi.isconnected():
    time.sleep(1)
    print("...")

print("Conectado!")
print("IP:", wifi.ifconfig())

# =========================
# SENSOR ULTRASONICO
# =========================
trig = Pin(18, Pin.OUT)
echo = Pin(19, Pin.IN)

# =========================
# FUNCION MEDIR DISTANCIA
# =========================
def medir_distancia():
    trig.off()
    time.sleep_us(2)

    trig.on()
    time.sleep_us(10)
    trig.off()

    duracion = time_pulse_us(echo, 1, 30000)  # timeout 30ms

    if duracion < 0:
        return None

    distancia = (duracion * 0.0343) / 2
    return distancia

# =========================
# FUNCION ENVIAR
# =========================
def enviar(variable, valor, unidad):
    data = {
        "variable": variable,
        "value": valor,
        "unit": unidad
    }

    try:
        response = urequests.post(url, json=data, headers=headers)
        print("Enviado:", variable, "|", valor, "| Status:", response.status_code)
        response.close()
    except Exception as e:
        print("Error enviando:", e)

# =========================
# LOOP PRINCIPAL
# =========================
while True:
    try:
        distancia = medir_distancia()

        if distancia is None:
            print("Error: no se detecta objeto")
        else:
            print("Distancia:", distancia, "cm")
            enviar("Distance", distancia, "cm")

        time.sleep(10)

    except Exception as e:
        print("Error general:", e)
        time.sleep(2)
