import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../../../data/models/models.dart';

Future<Uint8List> makePdfPisos(
    List<Piso> pisos,
    String arenaPisos,
    String cementoPisos,
    String piedraPisos) async {
  final pdf = Document();
//  final imageLogo = MemoryImage((await rootBundle.load('assets/technical_logo.png')).buffer.asUint8List());
  pdf.addPage(
    Page(
      build: (context) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text("Attention to: {invoice.customer}"),
                    Text('invoice.address'),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                /* SizedBox(
                  height: 150,
                  width: 150,
                  child: Image(imageLogo),
                )*/
              ],
            ),
            Container(height: 10),
            Padding(
              child: Text(
                "TITULO",
                style: Theme.of(context).header1,
              ),
              padding: const EdgeInsets.all(20),
            ),
            Container(height: 30),
            Table(
              border: TableBorder.all(color: PdfColors.black),
              children: [
                TableRow(
                  children: [
                    Padding(
                      child: Text(
                        'DATOS DEL METRADO',
                        style: Theme.of(context).header5,
                        textAlign: TextAlign.center,
                      ),
                      padding: const EdgeInsets.all(20),
                    ),
                    Padding(
                      child: Text(
                        'VOLUMEN (m3)',
                        style: Theme.of(context).header5,
                        textAlign: TextAlign.center,
                      ),
                      padding: const EdgeInsets.all(20),
                    ),
                  ],
                ),
                ...pisos.map(
                        (e) => TableRow(
                        children: [
                          PaddedText(e.description),
                          PaddedText((double.parse(e.largo) * double.parse(e.altura) * double.parse(e.ancho)).toString(), align: TextAlign.center)
                        ],
                        ),
                )
              ],
            ),
            Container(height: 30),
            Padding(
              child: Text(
                "LISTA DE MATERIALES",
                style: Theme.of(context).header1,
              ),
              padding: const EdgeInsets.all(20),
            ),
            /*Text("Please forward the below slip to your accounts payable department."),
            Divider(
              height: 1,
              borderStyle: BorderStyle.dashed,
            ),*/
            Container(height: 20),
            Table(
              border: TableBorder.all(color: PdfColors.black),
              children: [
                TableRow(
                    children: [
                      PaddedText(''),
                      PaddedText('UNIDAD', align: TextAlign.center),
                      PaddedText('CANTIDAD', align: TextAlign.center)
                    ]
                ),
                TableRow(
                  children: [
                    PaddedText('ARENA GRUESA'),
                    PaddedText('m3', align: TextAlign.center),
                    PaddedText(arenaPisos, align: TextAlign.center)
                  ],
                ),
                TableRow(
                  children: [
                    PaddedText('CEMENTO',),
                    PaddedText('bls', align: TextAlign.center),
                    PaddedText(cementoPisos, align: TextAlign.center)
                  ],
                ),
                if (pisos.first.tipo != 'contrapiso')
                  TableRow(
                    children: [
                      PaddedText(
                        'PIEDRA CHANCADA',
                      ),
                      PaddedText('und', align: TextAlign.center),
                      PaddedText(piedraPisos, align: TextAlign.center)
                    ],
                  )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Text(
                'Esto es una prueba, gracias!',
                style: Theme.of(context).header3.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        );
      },
    ),
  );
  return pdf.save();
}

Widget PaddedText(
    final String text, {
      final TextAlign align = TextAlign.left,
    }) =>
    Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: align,
      ),
    );