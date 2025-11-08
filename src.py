def converter_base():
    digitos_validos = "0123456789ABCDEF"

    while True:
        print("\n=== Conversor de Bases Numéricas ===")
        numero = input("Digite o número: ").strip().upper()

        try:
            base_origem = int(input("Digite a base de origem (2 a 16): "))
            base_destino = int(input("Digite a base de destino (2 a 16): "))
        except ValueError:
            print("Erro: as bases devem ser números inteiros entre 2 e 16.")
            continue

        if not (2 <= base_origem <= 16 and 2 <= base_destino <= 16):
            print("Erro: as bases devem estar entre 2 e 16.")
            continue

        for d in numero:
            if d not in digitos_validos[:base_origem]:
                print(f"Erro: '{d}' não é válido na base {base_origem}.")
                break
        else:
            decimal = 0
            expoente = len(numero) - 1
            for d in numero:
                valor = digitos_validos.index(d)
                decimal += valor * (base_origem ** expoente)
                expoente -= 1

            if decimal == 0:
                resultado = "0"
            else:
                resultado = ""
                while decimal > 0:
                    resto = decimal % base_destino
                    resultado = digitos_validos[resto] + resultado
                    decimal //= base_destino

            print(f"\n {numero} na base {base_origem} \n corresponde a \n {resultado} na base {base_destino}")

        continuar = input("\nDigite 's' para converter outro número ou qualquer outra tecla para sair: ").strip()
        if continuar.lower() != "s":
            print("Encerrando o programa...")
            break


converter_base()