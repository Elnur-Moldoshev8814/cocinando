import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../widgets/text_styles.dart';

class RecipeListPage extends StatelessWidget {
  final String category;
  const RecipeListPage({required this.category, super.key});

  @override
  Widget build(BuildContext context) {
    final recipes = _mockRecipes[category] ?? [];

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark, // светлые иконки
        statusBarBrightness: Brightness.light, // для iOS
    ),
    child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color.fromRGBO(0, 87, 248, 1)),
          onPressed: () => context.go('/recetas'),
        ),
        title: Text(category, style: AppTextStyles.appbarTitle),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return CustomExpansionTile(
            title: recipe['name'],
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16, left: 32, top: 12, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ingredientes", style: AppTextStyles.title_list),
                    const SizedBox(height: 8),
                    ...List<Widget>.from(recipe['ingredients'].map<Widget>((i) => Text(i, style: AppTextStyles.subtitle_list))),
                    const SizedBox(height: 16),
                    Text("Preparación", style: AppTextStyles.title_list),
                    const SizedBox(height: 8),
                    Text(recipe['preparation'], style: AppTextStyles.subtitle_list),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ));
  }
}

class CustomExpansionTile extends StatefulWidget {
  final String title;
  final List<Widget> children;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _size;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _rotation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _size = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
              letterSpacing: -0.02,
            ),
          ),
          trailing: RotationTransition(
            turns: _rotation,
            child: const Icon(Icons.keyboard_arrow_right,
                color: Color.fromRGBO(128, 128, 128, 1)),
          ),
          onTap: _toggleExpanded,
        ),
        ClipRect(
          child: SizeTransition(
            sizeFactor: _size,
            axisAlignment: 0.0,
            child: FadeTransition(
              opacity: _fade,
              child: Column(children: widget.children),
            ),
          ),
        ),
        const Divider(color: Color.fromRGBO(128, 128, 128, 0.5)),
      ],
    );
  }
}


const Map<String, List<Map<String, dynamic>>> _mockRecipes = {
  "Dietético": [
    {
      "name": "Avena con Frutos Rojos y Semillas de Chía",
      "ingredients": [
        "1/2 taza de avena en hojuelas",
        "1 taza de leche de almendras",
        "1 cucharada de semillas de chía",
        "1/2 taza de frutos rojos mixtos",
        "1 cucharadita de miel (opcional)"
      ],
      "preparation": "En una olla, calentar la leche de almendras y agregar la avena. Cocinar a fuego lento durante 5 minutos, revolviendo. Añadir las semillas de chía y mezclar bien. Servir con frutos rojos frescos y miel."
    },
    {
      "name": "Yogur Griego con Miel y Nueces",
      "ingredients": [
        "1 taza de yogur griego",
        "1 cucharada de miel",
        "2 cucharadas de nueces mixtas (almendras, nueces)"
      ],
      "preparation": "Mezclar el yogur griego con la miel. Decorar con nueces picadas y servir."
    },
    {
      "name": "Tostada de Aguacate en Pan Integral",
      "ingredients": [
        "1 rebanada de pan integral",
        "1/2 aguacate",
        "1 cucharadita de jugo de limón",
        "Sal y pimienta al gusto"
      ],
      "preparation": "Tostar el pan. Triturar el aguacate, mezclar con jugo de limón, sal y pimienta. Untar sobre la tostada y servir."
    },
    {
      "name": "Claras de Huevo Revueltas con Espinacas",
      "ingredients": [
        "3 claras de huevo",
        "1 taza de espinacas frescas",
        "1 cucharadita de aceite de oliva",
        "Sal y pimienta al gusto"
      ],
      "preparation": "Calentar el aceite en una sartén y saltear las espinacas. Agregar las claras y revolver hasta que estén cocidas. Sazonar con sal y pimienta."
    },
    {
      "name": "Ensalada de Pollo a la Parrilla con Aderezo de Limón",
      "ingredients": [
        "1 pechuga de pollo a la parrilla",
        "2 tazas de mezcla de hojas verdes",
        "1/2 taza de tomates cherry, cortados por la mitad",
        "1/4 taza de rodajas de pepino",
        "1 cucharada de aceite de oliva",
        "1 cucharada de jugo de limón",
        "Sal y pimienta al gusto"
      ],
      "preparation": "Cortar la pechuga de pollo en tiras. Mezclar las hojas verdes, tomates y pepino en un tazón. Añadir el pollo, rociar con aceite y jugo de limón. Mezclar y servir."
    },
    {
      "name": "Tazón de Quinoa con Verduras Asadas",
      "ingredients": [
        "1/2 taza de quinoa",
        "1 calabacín, picado",
        "1 pimiento rojo, picado",
        "1 cucharada de aceite de oliva",
        "Sal y pimienta al gusto"
      ],
      "preparation": "Cocinar la quinoa según las instrucciones del paquete. Asar las verduras con aceite a 190°C durante 20 minutos. Combinar la quinoa con las verduras asadas."
    },
    {
      "name": "Sopa de Lentejas con Cúrcuma",
      "ingredients": [
        "1 taza de lentejas",
        "1 cebolla, picada",
        "2 zanahorias, picadas",
        "1 cucharadita de cúrcuma",
        "4 tazas de caldo de verduras"
      ],
      "preparation": "Saltear la cebolla y las zanahorias en una olla. Agregar las lentejas, cúrcuma y caldo. Cocinar a fuego lento durante 30 minutos."
    },
    {
      "name": "Fideos de Calabacín con Pesto",
      "ingredients": [
        "1 calabacín, en espiral",
        "2 cucharadas de salsa pesto",
        "1 cucharada de aceite de oliva"
      ],
      "preparation": "Saltear los fideos de calabacín en aceite durante 2 minutos. Mezclar con pesto y servir."
    },
    {
      "name": "Bacalao al Horno con Limón y Hierbas",
      "ingredients": [
        "1 filete de bacalao",
        "1 cucharada de jugo de limón",
        "1 cucharadita de orégano seco",
        "Sal y pimienta al gusto"
      ],
      "preparation": "Colocar el bacalao en una bandeja para hornear. Rociar con jugo de limón y sazonar con hierbas. Hornear a 190°C durante 15 minutos."
    },
    {
      "name": "Tofu a la Parrilla con Verduras Salteadas",
      "ingredients": [
        "1 bloque de tofu firme, en rebanadas",
        "1 taza de verduras mixtas (pimientos, zanahorias, brócoli)",
        "1 cucharada de salsa de soja"
      ],
      "preparation": "Dorar las rebanadas de tofu en la parrilla. Saltear las verduras y añadir salsa de soja. Servir el tofu con las verduras."
    },
    {
      "name": "Hummus con Bastones de Zanahoria y Pepino",
      "ingredients": [
        "1/2 taza de hummus",
        "1 zanahoria, cortada en bastones",
        "1/2 pepino, cortado en bastones"
      ],
      "preparation": "Servir el hummus con los bastones de verdura."
    },
    {
      "name": "Rodajas de Manzana con Mantequilla de Cacahuete",
      "ingredients": [
        "1 manzana, en rodajas",
        "1 cucharada de mantequilla de cacahuete"
      ],
      "preparation": "Untar la mantequilla de cacahuete sobre las rodajas de manzana."
    },
    {
      "name": "Sorbete de Frutos Rojos sin Azúcar",
      "ingredients": [
        "1 taza de frutos rojos congelados",
        "1/2 plátano",
        "1/2 taza de agua"
      ],
      "preparation": "Triturar todos los ingredientes hasta obtener una mezcla homogénea. Congelar durante 1 hora antes de servir."
    },
    {
      "name": "Panqueques de Plátano (sin Harina ni Azúcar)",
      "ingredients": [
        "1 plátano maduro",
        "2 huevos",
        "1/2 cucharadita de canela"
      ],
      "preparation": "Machacar el plátano y mezclar con los huevos y canela. Cocinar en una sartén como panqueques tradicionales."
    },
    {
      "name": "Mousse de Chocolate y Aguacate",
      "ingredients": [
        "1 aguacate maduro",
        "2 cucharadas de cacao en polvo",
        "1 cucharada de miel"
      ],
      "preparation": "Licuar todos los ingredientes hasta que quede cremoso. Refrigerar antes de servir."
    },
    {
      "name": "Boniato Asado con Canela",
      "ingredients": [
        "1 boniato mediano",
        "1/2 cucharadita de canela",
        "1 cucharadita de aceite de oliva"
      ],
      "preparation": "Precalentar el horno a 200°C. Cortar el boniato en rodajas, pintar con aceite y espolvorear canela. Hornear durante 25-30 minutos hasta que estén tiernos."
    },
    {
      "name": "Arroz de Coliflor con Gambas",
      "ingredients": [
        "1 taza de arroz de coliflor",
        "6 gambas, peladas y desvenadas",
        "1 diente de ajo, picado",
        "1 cucharada de aceite de oliva",
        "Sal y pimienta al gusto"
      ],
      "preparation": "Calentar el aceite en una sartén, añadir ajo y gambas, cocinar 3-4 minutos. Agregar el arroz de coliflor y cocinar 3 minutos más."
    },
    {
      "name": "Arroz Integral con Champiñones Salteados",
      "ingredients": [
        "1/2 taza de arroz integral",
        "1 taza de champiñones, en láminas",
        "1 cucharada de aceite de oliva",
        "Sal y pimienta al gusto"
      ],
      "preparation": "Cocinar el arroz según las instrucciones del paquete. Saltear los champiñones en aceite y mezclar con el arroz."
    },
    {
      "name": "Calabaza Espagueti con Salsa de Tomate",
      "ingredients": [
        "1 calabaza espagueti",
        "1 taza de salsa de tomate",
        "1 cucharada de aceite de oliva"
      ],
      "preparation": "Cortar la calabaza por la mitad y hornear a 190°C durante 40 minutos. Raspar con un tenedor para obtener 'fideos'. Mezclar con la salsa de tomate y servir."
    },
    {
      "name": "Brócoli al Vapor con Limón",
      "ingredients": [
        "1 taza de floretes de brócoli",
        "1 cucharada de jugo de limón",
        "Sal y pimienta al gusto"
      ],
      "preparation": "Cocinar al vapor el brócoli durante 5 minutos. Rociar con jugo de limón y sazonar."
    },
    {
      "name": "Bocados de Almendras y Chocolate Negro",
      "ingredients": [
        "10 almendras",
        "1 trozo pequeño de chocolate negro (85% cacao)"
      ],
      "preparation": "Disfrutar como snack saludable."
    },
    {
      "name": "Requesón con Frutos Rojos Frescos",
      "ingredients": [
        "1/2 taza de requesón",
        "1/2 taza de frutos rojos mixtos"
      ],
      "preparation": "Mezclar y servir frío."
    },
    {
      "name": "Huevos Duros con Aguacate",
      "ingredients": [
        "2 huevos",
        "1/2 aguacate"
      ],
      "preparation": "Hervir los huevos, pelarlos y servir con aguacate machacado."
    },
    {
      "name": "Chips de Kale con Sal Marina",
      "ingredients": [
        "1 taza de hojas de kale",
        "1 cucharada de aceite de oliva",
        "Sal marina al gusto"
      ],
      "preparation": "Precalentar el horno a 175°C. Mezclar el kale con aceite y hornear 10-15 minutos."
    },
    {
      "name": "Batido Verde Detox con Espinacas y Jengibre",
      "ingredients": [
        "1 taza de espinacas",
        "1 plátano",
        "1 cucharadita de jengibre rallado",
        "1 taza de agua"
      ],
      "preparation": "Licuar todo hasta que quede suave."
    },
    {
      "name": "Agua de Coco con Semillas de Chía",
      "ingredients": [
        "1 taza de agua de coco",
        "1 cucharada de semillas de chía"
      ],
      "preparation": "Mezclar y dejar reposar 10 minutos."
    }
  ],
  "Vegetariano": [
      {
        "name": "Panqueques de Avena y Plátano",
        "ingredients": [
          "1 plátano maduro",
          "½ taza de avena en hojuelas",
          "1 huevo (o huevo de linaza para opción vegana)",
          "½ cucharadita de canela"
        ],
        "preparation": "Licúa todos los ingredientes hasta obtener una mezcla homogénea. Calienta una sartén antiadherente y cocina pequeños panqueques durante 2 minutos por cada lado."
      },
      {
        "name": "Pudín de Chía con Leche de Almendras",
        "ingredients": [
          "2 cucharadas de semillas de chía",
          "1 taza de leche de almendras",
          "1 cucharadita de miel (o jarabe de arce para opción vegana)"
        ],
        "preparation": "Mezcla las semillas de chía con la leche de almendras. Deja reposar en el refrigerador durante la noche. Remueve antes de servir y acompaña con fruta fresca."
      },
      {
        "name": "Tostada de Aguacate con Tomates Cherry",
        "ingredients": [
          "1 rebanada de pan integral",
          "½ aguacate",
          "3 tomates cherry, en rodajas",
          "Sal y pimienta al gusto"
        ],
        "preparation": "Tuesta el pan. Tritura el aguacate y úntalo sobre la tostada. Agrega los tomates y sazona."
      },
      {
        "name": "Tazón de Smoothie con Nueces y Semillas",
        "ingredients": [
          "1 plátano",
          "½ taza de frutos rojos congelados",
          "½ taza de leche de almendras",
          "1 cucharada de semillas de chía",
          "1 cucharada de nueces mixtas"
        ],
        "preparation": "Licúa el plátano, los frutos rojos y la leche de almendras. Vierte en un tazón y decora con las semillas de chía y las nueces."
      },
      {
        "name": "Tofu Revuelto con Verduras",
        "ingredients": [
          "½ taza de tofu firme, desmenuzado",
          "½ pimiento, picado",
          "½ cucharadita de cúrcuma",
          "1 cucharada de aceite de oliva",
          "Sal y pimienta al gusto"
        ],
        "preparation": "Calienta el aceite de oliva y saltea el pimiento. Agrega el tofu desmenuzado, la cúrcuma, la sal y la pimienta. Cocina durante 5 minutos y sirve."
      },
      {
        "name": "Ensalada de Quinoa con Aderezo de Limón",
        "ingredients": [
          "½ taza de quinoa cocida",
          "½ pepino, picado",
          "½ taza de tomates cherry, cortados a la mitad",
          "1 cucharada de aceite de oliva",
          "1 cucharada de jugo de limón"
        ],
        "preparation": "Mezcla la quinoa, el pepino y los tomates. Rocía con el aceite de oliva y el jugo de limón."
      },
      {
        "name": "Sopa de Lentejas con Zanahorias",
        "ingredients": [
          "1 taza de lentejas",
          "1 zanahoria, picada",
          "1 cebolla, picada",
          "4 tazas de caldo de verduras",
          "1 cucharadita de comino"
        ],
        "preparation": "Sofríe la cebolla y la zanahoria en una olla. Agrega las lentejas, el caldo y el comino. Cocina a fuego lento durante 30 minutos."
      },
      {
        "name": "Fideos de Calabacín con Pesto",
        "ingredients": [
          "1 calabacín, en espiral",
          "2 cucharadas de pesto",
          "1 cucharada de aceite de oliva"
        ],
        "preparation": "Saltea los fideos de calabacín durante 2 minutos. Mézclalos con el pesto y sirve."
      },
      {
        "name": "Pimientos Rellenos con Arroz",
        "ingredients": [
          "1 pimiento, cortado por la mitad",
          "½ taza de arroz integral cocido",
          "½ taza de frijoles negros",
          "1 cucharada de salsa de tomate"
        ],
        "preparation": "Mezcla el arroz, los frijoles y la salsa de tomate. Rellena las mitades de pimiento y hornea a 190 °C (375 °F) durante 20 minutos."
      },
      {
        "name": "Ensalada de Garbanzos con Aderezo de Tahini",
        "ingredients": [
          "1 taza de garbanzos enlatados, escurridos",
          "½ pepino, picado",
          "1 cucharada de tahini",
          "1 cucharada de jugo de limón"
        ],
        "preparation": "Mezcla los garbanzos y el pepino. Rocía con tahini y jugo de limón."
      },
      {
        "name": "Salteado de Verduras con Tofu",
        "ingredients": [
          "½ taza de tofu, cortado en cubos",
          "1 taza de verduras mixtas (brócoli, pimiento, zanahoria)",
          "1 cucharada de salsa de soja"
        ],
        "preparation": "Sofríe el tofu hasta que esté dorado. Agrega las verduras y la salsa de soja. Cocina durante 5 minutos."
      },
      {
        "name": "Risotto de Champiñones",
        "ingredients": [
          "½ taza de arroz Arborio",
          "1 taza de champiñones, en rodajas",
          "2 tazas de caldo de verduras",
          "1 cucharada de aceite de oliva"
        ],
        "preparation": "Sofríe los champiñones en el aceite de oliva. Agrega el arroz y el caldo gradualmente, revolviendo hasta que quede cremoso."
      },
      {
        "name": "Berenjena a la Parmesana (Horneada)",
        "ingredients": [
          "1 berenjena, en rodajas",
          "1 taza de salsa de tomate",
          "½ taza de queso mozzarella (o alternativa vegana)"
        ],
        "preparation": "Coloca en capas la berenjena, la salsa y el queso en una fuente para hornear. Hornea a 190 °C (375 °F) durante 25 minutos."
      },
      {
        "name": "Arroz de Coliflor con Verduras",
        "ingredients": [
          "1 taza de arroz de coliflor",
          "½ taza de verduras mixtas",
          "1 cucharada de aceite de oliva"
        ],
        "preparation": "Sofríe las verduras en el aceite de oliva. Agrega el arroz de coliflor y cocina durante 3 minutos."
      },
      {
        "name": "Espaguetis con Salsa de Tomate y Albahaca",
        "ingredients": [
          "1 taza de espaguetis integrales",
          "1 taza de salsa de tomate",
          "¼ taza de albahaca fresca"
        ],
        "preparation": "Cocina los espaguetis y mézclalos con la salsa de tomate. Decora con albahaca fresca."
      },
      {
        "name": "Garbanzos Asados con Pimentón",
        "ingredients": [
          "1 taza de garbanzos enlatados, escurridos",
          "1 cucharada de aceite de oliva",
          "½ cucharadita de pimentón",
          "¼ cucharadita de sal"
        ],
        "preparation": "Precalienta el horno a 200 °C (400 °F). Mezcla los garbanzos con el aceite de oliva, el pimentón y la sal. Hornea durante 25 minutos hasta que estén crujientes."
      },
      {
        "name": "Ensalada de Pepino y Aguacate",
        "ingredients": [
          "1 pepino, en rodajas",
          "½ aguacate, en cubos",
          "1 cucharada de aceite de oliva",
          "Sal y pimienta al gusto"
        ],
        "preparation": "Mezcla el pepino y el aguacate en un tazón. Rocía con aceite de oliva y sazona con sal y pimienta."
      },
      {
        "name": "Hummus con Palitos de Zanahoria",
        "ingredients": [
          "½ taza de hummus",
          "1 zanahoria, cortada en palitos"
        ],
        "preparation": "Sirve el hummus con los palitos de zanahoria para mojar."
      },
      {
        "name": "Rodajas de Manzana con Mantequilla de Maní",
        "ingredients": [
          "1 manzana, en rodajas",
          "1 cucharada de mantequilla de maní"
        ],
        "preparation": "Unta la mantequilla de maní sobre las rodajas de manzana."
      },
      {
        "name": "Chips de Col Rizada con Sal Marina",
        "ingredients": [
          "1 taza de hojas de col rizada",
          "1 cucharada de aceite de oliva",
          "Sal marina al gusto"
        ],
        "preparation": "Precalienta el horno a 175 °C (350 °F). Mezcla la col rizada con el aceite de oliva y hornea durante 10-15 minutos."
      },
      {
        "name": "Smoothie Verde con Espinacas y Plátano",
        "ingredients": [
          "1 taza de espinacas",
          "1 plátano",
          "1 taza de leche de almendras"
        ],
        "preparation": "Licúa todos los ingredientes hasta obtener una mezcla homogénea."
      },
      {
        "name": "Chocolate Oscuro y Nueces",
        "ingredients": [
          "1 trozo pequeño de chocolate oscuro (85% cacao)",
          "10 almendras"
        ],
        "preparation": "Disfruta como un tentempié rápido y saludable."
      },
      {
        "name": "Sandía Fría con Menta",
        "ingredients": [
          "1 taza de sandía en cubos",
          "1 cucharada de menta picada"
        ],
        "preparation": "Mezcla los ingredientes y sirve fría."
      },
      {
        "name": "Papas Fritas de Batata al Horno",
        "ingredients": [
          "1 batata, cortada en tiras",
          "1 cucharada de aceite de oliva",
          "½ cucharadita de pimentón"
        ],
        "preparation": "Precalienta el horno a 200 °C (400 °F). Mezcla las tiras de batata con el aceite de oliva y el pimentón. Hornea durante 25 minutos."
      },
      {
        "name": "Sorbete de Frutos Rojos (Sin Azúcar)",
        "ingredients": [
          "1 taza de frutos rojos mixtos congelados",
          "½ plátano",
          "½ taza de agua"
        ],
        "preparation": "Licúa todos los ingredientes hasta obtener una mezcla homogénea. Congela durante 1 hora antes de servir."
      }
    ],
  "Rápido y Fácil": [
    {
      "name": "Tostada de Aguacate",
      "ingredients": [
        "1 aguacate maduro",
        "2 rebanadas de pan",
        "Sal y pimienta",
        "Jugo de limón"
      ],
      "preparation": "Tuesta el pan. Tritura el aguacate con un tenedor y sazona con sal, pimienta y un chorrito de jugo de limón. Unta sobre la tostada."
    },
    {
      "name": "Pasta Aglio e Olio",
      "ingredients": [
        "200 g de espaguetis",
        "3 dientes de ajo (en rodajas)",
        "4 cucharadas de aceite de oliva",
        "Copos de pimiento rojo (opcional)",
        "Perejil fresco"
      ],
      "preparation": "Cocina la pasta según las instrucciones del paquete. Calienta el aceite de oliva, sofrie el ajo hasta que esté fragante y luego agrega la pasta cocida. Espolvorea con perejil y copos de pimiento rojo."
    },
    {
      "name": "Sándwich de Queso a la Parrilla",
      "ingredients": [
        "2 rebanadas de pan",
        "2 rebanadas de queso",
        "Mantequilla"
      ],
      "preparation": "Unta mantequilla en ambos lados del pan. Coloca el queso entre las rebanadas y grill en una sartén hasta que esté dorado y el queso se derrita."
    },
    {
      "name": "Ensalada de Huevo",
      "ingredients": [
        "4 huevos cocidos",
        "3 cucharadas de mayonesa",
        "Sal y pimienta",
        "Perejil picado"
      ],
      "preparation": "Pica los huevos y mézcialos con la mayonesa, sal, pimienta y perejil. Sirve sobre tostadas o como sándwich."
    },
    {
      "name": "Ensalada Caprese",
      "ingredients": [
        "2 tomates",
        "150 g de mozzarella",
        "Albahaca fresca",
        "Aceite de oliva, vinagre balsámico"
      ],
      "preparation": "Corta los tomates y la mozzarella. Colócalos en un plato, rocia con aceite de oliva y vinagre balsámico, y decora con albahaca."
    },
    {
      "name": "Sopa de Tomate",
      "ingredients": [
        "1 lata de sopa de tomate",
        "1 lata de agua o leche",
        "Sal, pimienta y hierbas (opcional)"
      ],
      "preparation": "Calienta la sopa en la estufa con agua o leche. Sazona y sirve con galletas saladas."
    },
    {
      "name": "Panqueques de Plátano",
      "ingredients": [
        "1 plátano maduro",
        "2 huevos",
        "1 cucharadita de polvo de hornear",
        "Canela (opcional)"
      ],
      "preparation": "Tritura el plátano y mézclalo con los huevos, el polvo de hornear y la canela. Fría en una sartén antiadherente hasta que estén dorados por ambos lados."
    },
    {
      "name": "Tazón de Smoothie",
      "ingredients": [
        "1 plátano",
        "1 taza de frutos rojos congelados",
        "1/2 taza de yogur",
        "Toppings (granola, copos de coco)"
      ],
      "preparation": "Licúa el plátano, los frutos rojos y el yogur. Vierte en un tazón y agrega tus toppings favoritos."
    },
    {
      "name": "Ensalada de Atún",
      "ingredients": [
        "1 lata de atún",
        "2 cucharadas de mayonesa",
        "1 cucharada de mostaza",
        "Cebolla y apio picados"
      ],
      "preparation": "Mezcla el atún con la mayonesa, la mostaza y las verduras. Sirve sobre pan o galletas saladas."
    },
    {
      "name": "Quesadilla de Pollo",
      "ingredients": [
        "2 tortillas",
        "1 taza de pollo cocido (desmenuzado)",
        "1 taza de queso",
        "Salsa"
      ],
      "preparation": "Rellena las tortillas con pollo y queso. Calienta en una sartén hasta que estén doradas, luego córtalas en triángulos. Sirve con salsa."
    },
    {
      "name": "Parfait de Yogur Griego",
      "ingredients": [
        "1 taza de yogur griego",
        "2 cucharadas de miel",
        "1 taza de granola",
        "Frutos rojos frescos"
      ],
      "preparation": "Coloca capas de yogur, miel, granola y frutos rojos en un vaso o tazón."
    },
    {
      "name": "Arroz Frito",
      "ingredients": [
        "1 taza de arroz cocido",
        "2 huevos",
        "1/2 taza de verduras mixtas",
        "Salsa de soja"
      ],
      "preparation": "Sofrie las verduras, revuelve los huevos, luego agrega el arroz y la salsa de soja. Remueve hasta que todo esté bien caliente."
    },
    {
      "name": "Salsa de Mango",
      "ingredients": [
        "1 mango (en cubos)",
        "1/2 cebolla roja (picada)",
        "1 lima (jugo)",
        "Cilantro"
      ],
      "preparation": "Mezcla todos los ingredientes y sirve con totopos o como acompañamiento."
    },
    {
      "name": "Wrap de Verduras",
      "ingredients": [
        "1 tortilla",
        "1 taza de verduras mixtas (lechuga, pepino, aguacate)",
        "2 cucharadas de hummus"
      ],
      "preparation": "Unta el hummus en la tortilla, agrega las verduras, enrolla y disfruta."
    },
    {
      "name": "Tostada de Mantequilla de Maní y Plátano",
      "ingredients": [
        "1 rebanada de pan",
        "2 cucharadas de mantequilla de maní",
        "1 plátano"
      ],
      "preparation": "Tuesta el pan, unta con mantequilla de maní y coloca las rodajas de plátano por encima."
    },
    {
      "name": "Queso y Galletas Saladas",
      "ingredients": [
        "Tus galletas saladas favoritas",
        "Rodajas de queso (cheddar, brie, etc.)"
      ],
      "preparation": "Simplemente coloca el queso y las galletas saladas en un plato. Sirve con uvas o aceitunas si lo deseas."
    },
  ],
  "Casero Clásico": [
    {
      "name": "Chocolate Oscuro y Nueces",
      "ingredients": [
        "1 trozo pequeño de chocolate oscuro (85% cacao)",
        "10 almendras"
      ],
      "preparation": "Disfruta como un tentempié rápido y saludable."
    },
    {
      "name": "Espaguetis a la Boloñesa",
      "ingredients": [
        "500 g de carne molida de res",
        "1 cebolla (picada)",
        "2 dientes de ajo (picados)",
        "1 lata de pasta de tomate",
        "1 lata de tomates en cubos",
        "2 cucharadas de aceite de oliva",
        "Sal y pimienta",
        "300 g de espaguetis"
      ],
      "preparation": "Cocina los espaguetis según las instrucciones del paquete. Calienta el aceite de oliva, sofríe la cebolla y el ajo, luego agrega la carne y cocina hasta que se dore. Añade la pasta de tomate, los tomates en cubos, sal y pimienta. Cocina a fuego lento durante 30 minutos y sirve con los espaguetis."
    },
    {
      "name": "Pastel de Carne Casero",
      "ingredients": [
        "500 g de carne molida de res",
        "1 cebolla (picada)",
        "1 huevo",
        "1/2 taza de pan rallado",
        "2 cucharadas de ketchup",
        "Sal y pimienta"
      ],
      "preparation": "Precalienta el horno a 190°C (375°F). Mezcla todos los ingredientes en un tazón. Forma un pan y hornea durante 45-50 minutos, glaseando con ketchup a la mitad de la cocción."
    },
    {
      "name": "Pastel de Pollo",
      "ingredients": [
        "2 pechugas de pollo (cocidas y desmenuzadas)",
        "1 taza de verduras mixtas congeladas",
        "1 lata de crema de sopa de pollo",
        "1 taza de caldo de pollo",
        "1 paquete de masa para pastel",
        "Sal y pimienta"
      ],
      "preparation": "Precalienta el horno a 200°C (400°F). En un tazón, mezcla el pollo, las verduras, la sopa y el caldo. Sazona con sal y pimienta. Coloca la mezcla en un molde para pastel y cúbrelo con la masa. Hornea durante 30 minutos."
    },
    {
      "name": "Macarrones con Queso Caseros",
      "ingredients": [
        "300 g de macarrones en codo",
        "2 tazas de queso cheddar rallado",
        "2 cucharadas de mantequilla",
        "2 cucharadas de harina",
        "2 tazas de leche",
        "Sal y pimienta"
      ],
      "preparation": "Cocina los macarrones según las instrucciones del paquete. En una sartén, derrite la mantequilla y luego agrega la harina. Agrega la leche lentamente y cocina hasta que espese. Añade el queso y sazona con sal y pimienta. Mezcla la pasta con la salsa y sirve."
    },
    {
      "name": "Estofado de Carne",
      "ingredients": [
        "500 g de carne para estofado",
        "2 zanahorias (en rodajas)",
        "2 papas (en cubos)",
        "1 cebolla (picada)",
        "2 tazas de caldo de carne",
        "2 cucharadas de harina",
        "2 cucharadas de aceite de oliva",
        "Sal y pimienta"
      ],
      "preparation": "Dora la carne en el aceite de oliva. Añade la harina y cocina durante un minuto. Agrega el caldo, las verduras, sal y pimienta. Cocina a fuego lento durante 1-1.5 horas, hasta que la carne esté tierna."
    },
    {
      "name": "Pollo Asado",
      "ingredients": [
        "1 pollo entero",
        "2 cucharadas de aceite de oliva",
        "1 limón (cortado por la mitad)",
        "3 dientes de ajo (machacados)",
        "Romero fresco",
        "Sal y pimienta"
      ],
      "preparation": "Precalienta el horno a 190°C (375°F). Frota el pollo con el aceite de oliva, sal, pimienta, limón, ajo y romero. Ásalo durante 1-1.5 horas, hasta que el pollo esté dorado y bien cocido."
    },
    {
      "name": "Pollo Alfredo",
      "ingredients": [
        "2 pechugas de pollo (en rodajas)",
        "300 g de fettuccine",
        "1 taza de crema espesa",
        "2 cucharadas de mantequilla",
        "1 taza de queso parmesano rallado",
        "Sal y pimienta"
      ],
      "preparation": "Cocina el fettuccine según las instrucciones del paquete. En una sartén, cocina el pollo y reserva. En la misma sartén, derrite la mantequilla, agrega la crema y el parmesano. Revuelve hasta que espese. Mezcla la pasta y el pollo con la salsa y sirve."
    },
    {
      "name": "Tacos Clásicos de Carne",
      "ingredients": [
        "500 g de carne molida de res",
        "1 paquete de condimento para tacos",
        "8 conchas para tacos",
        "1 cebolla (picada)",
        "1 tomate (picado)",
        "Lechuga, queso, crema agria (para cubrir)"
      ],
      "preparation": "Dora la carne molida en una sartén con las cebollas. Agrega el condimento para tacos y agua según las instrucciones del paquete. Calienta las conchas para tacos y rellénalas con la carne, tomate, lechuga, queso y crema agria."
    },
    {
      "name": "Lasaña",
      "ingredients": [
        "500 g de carne molida de res",
        "9 láminas de lasaña",
        "1 frasco de salsa marinara",
        "2 tazas de queso ricotta",
        "1 huevo",
        "2 tazas de queso mozzarella rallado",
        "1/2 taza de queso parmesano rallado"
      ],
      "preparation": "Precalienta el horno a 190°C (375°F). Cocina las láminas de lasaña. Dora la carne en una sartén y agrega la salsa marinara. En un tazón, mezcla el ricotta, el huevo y la mitad del queso mozzarella. Coloca capas de láminas de lasaña, salsa de carne, mezcla de ricotta y mozzarella en una fuente para hornear. Hornea durante 45 minutos."
    },
    {
      "name": "Salteado de Carne y Brócoli",
      "ingredients": [
        "500 g de tiras de carne",
        "1 taza de flores de brócoli",
        "3 cucharadas de salsa de soja",
        "1 cucharada de salsa de ostras",
        "2 dientes de ajo (picados)",
        "1 cucharada de maicena",
        "2 cucharadas de aceite de oliva"
      ],
      "preparation": "Saltea la carne en el aceite hasta que se dore. Agrega el ajo, el brócoli, la salsa de soja y la salsa de ostras. Cocina hasta que el brócoli esté tierno. Disuelve la maicena en agua y agrégala para espesar la salsa."
    },
    {
      "name": "Ensalada César Clásica",
      "ingredients": [
        "4 tazas de lechuga romana",
        "1 taza de crutones",
        "1/2 taza de queso parmesano",
        "1/4 taza de aderezo César"
      ],
      "preparation": "Mezcla la lechuga con el aderezo, los crutones y el queso. Sirve bien fría."
    },
    {
      "name": "Chili de Carne",
      "ingredients": [
        "500 g de carne molida de res",
        "1 cebolla (picada)",
        "1 lata de frijoles rojos",
        "1 lata de tomates picados",
        "2 cucharadas de chile en polvo",
        "1 cucharadita de comino",
        "Sal y pimienta"
      ],
      "preparation": "Dora la carne con la cebolla, luego agrega el chile en polvo y el comino. Agrega los tomates, los frijoles, sal y pimienta. Cocina a fuego lento durante 30 minutos."
    },
    {
      "name": "Pancakes Caseros",
      "ingredients": [
        "1 taza de harina de trigo",
        "1 cucharada de azúcar",
        "1 cucharadita de polvo de hornear",
        "1 huevo",
        "1 taza de leche",
        "2 cucharadas de mantequilla derretida"
      ],
      "preparation": "Mezcla los ingredientes secos en un tazón y los ingredientes húmedos en otro. Combina ambos y revuelve. Cocina en una plancha caliente hasta que se formen burbujas, luego voltea."
    },
    {
      "name": "Pizza Casera",
      "ingredients": [
        "1 masa para pizza",
        "1 taza de salsa para pizza",
        "2 tazas de queso mozzarella rallado",
        "Ingredientes para cubrir (pepperoni, verduras)"
      ],
      "preparation": "Precalienta el horno a 245°C (475°F). Estira la masa, unta con la salsa, agrega el queso y los ingredientes para cubrir. Hornea durante 12-15 minutos hasta que la corteza esté dorada."
    },
    {
      "name": "Ensalada de Papa",
      "ingredients": [
        "4 papas cocidas",
        "1/2 taza de mayonesa",
        "1 cucharada de mostaza",
        "1 huevo cocido (picado)",
        "Sal y pimienta"
      ],
      "preparation": "Corta las papas en cubos y mézclalas con la mayonesa, la mostaza, el huevo, la sal y la pimienta. Refrigera antes de servir."
    },
    {
      "name": "Verduras Asadas",
      "ingredients": [
        "2 zanahorias (en rodajas)",
        "1 calabacín (en rodajas)",
        "1 pimiento (picado)",
        "2 cucharadas de aceite de oliva",
        "Sal y pimienta"
      ],
      "preparation": "Precalienta el horno a 200°C (400°F). Mezcla las verduras con el aceite de oliva, sal y pimienta. Asa durante 25-30 minutos."
    },
    {
      "name": "Sopa Clásica de Almejas",
      "ingredients": [
        "1 lata de almejas",
        "2 papas (en cubos)",
        "1 cebolla (picada)",
        "1 taza de crema espesa",
        "2 tazas de caldo de pollo",
        "Sal y pimienta"
      ],
      "preparation": "Sofríe la cebolla, agrega las papas y el caldo. Cocina a fuego lento hasta que las papas estén tiernas. Agrega las almejas y la crema, sazona y cocina durante 5 minutos más."
    },
    {
      "name": "Berenjenas a la Parmesana",
      "ingredients": [
        "1 berenjena (en rodajas)",
        "1 taza de salsa marinara",
        "2 tazas de mozzarella",
        "1/2 taza de parmesano",
        "1 huevo (batido)",
        "Pan rallado"
      ],
      "preparation": "Precalienta el horno a 190°C (375°F). Pasa las rodajas de berenjena por el huevo y luego por el pan rallado. Fríe hasta que estén doradas. Coloca en un molde para hornear, alternando con la salsa y el queso, luego hornea durante 20 minutos."
    },
    {
      "name": "Bizcochos Caseros",
      "ingredients": [
        "2 tazas de harina para todo uso",
        "1 cucharada de polvo de hornear",
        "1/2 taza de mantequilla (fría)",
        "3/4 taza de leche"
      ],
      "preparation": "Precalienta el horno a 220°C (425°F). Mezcla los ingredientes secos, luego incorpora la mantequilla. Agrega la leche y revuelve hasta formar la masa. Coloca cucharadas de la masa en una bandeja para hornear y hornea durante 10-12 minutos."
    },
    {
      "name": "Tostadas Francesas Clásicas",
      "ingredients": [
        "2 huevos",
        "1/2 taza de leche",
        "4 rebanadas de pan",
        "Mantequilla",
        "Jarabe de arce"
      ],
      "preparation": "Bate los huevos y la leche. Sumerge las rebanadas de pan en la mezcla y fríelas en mantequilla hasta que estén doradas. Sirve con jarabe de arce."
    },
    {
      "name": "Hamburguesa Clásica con Queso",
      "ingredients": [
        "500 g de carne molida de res",
        "4 panes de hamburguesa",
        "Rebanadas de queso",
        "Lechuga, tomate, cebolla",
        "Sal y pimienta"
      ],
      "preparation": "Forma la carne en hamburguesas y sazona con sal y pimienta. Hazlas a la parrilla o fríelas en la sartén hasta el punto de cocción deseado. Sirve en los panes con queso, lechuga, tomate y cebolla."
    },
    {
      "name": "Schnitzel de Cerdo",
      "ingredients": [
        "4 filetes de cerdo",
        "1 taza de pan rallado",
        "2 huevos",
        "Harina",
        "Aceite para freír"
      ],
      "preparation": "Pasa los filetes de cerdo por harina, luego sumérgelos en los huevos batidos y cubre con pan rallado. Fríe en aceite hasta que estén dorados por ambos lados."
    },
    {
      "name": "Pollo a la Parmesana",
      "ingredients": [
        "4 pechugas de pollo",
        "1 taza de salsa marinara",
        "2 tazas de mozzarella",
        "1/2 taza de parmesano",
        "1 huevo",
        "Pan rallado"
      ],
      "preparation": "Precalienta el horno a 190°C (375°F). Cubre las pechugas de pollo con pan rallado y fríe hasta que estén doradas. Coloca salsa y queso sobre el pollo, luego hornea durante 15-20 minutos."
    },
    {
      "name": "Beef Wellington",
      "ingredients": [
        "500 g de solomillo de res",
        "1 lámina de masa de hojaldre",
        "2 cucharadas de mostaza Dijon",
        "1 taza de champiñones (picados)",
        "1 huevo (batido)"
      ],
      "preparation": "Dora el solomillo de res y cúbrelo con la mostaza. Saltea los champiñones y envuelve el solomillo en los champiñones, luego en la masa de hojaldre. Hornea durante 30-40 minutos a 200°C (400°F)."
    },
    {
      "name": "Salsa (Gravy)",
      "ingredients": [
        "2 cucharadas de mantequilla",
        "2 cucharadas de harina",
        "2 tazas de caldo de res",
        "Sal y pimienta"
      ],
      "preparation": "Derrite la mantequilla y agrega la harina, batiendo constantemente. Añade lentamente el caldo y revuelve hasta que espese. Sazona con sal y pimienta al gusto."
    },
    {
      "name": "Muffins Caseros",
      "ingredients": [
        "2 tazas de harina",
        "1 taza de azúcar",
        "1 cucharada de polvo de hornear",
        "1 huevo",
        "1 taza de leche",
        "1/2 taza de mantequilla"
      ],
      "preparation": "Precalienta el horno a 190°C (375°F). Mezcla los ingredientes secos y los ingredientes húmedos por separado, luego combínalos. Vierte la mezcla en un molde para muffins y hornea durante 15-20 minutos."
    },
    {
      "name": "Asado de Carne",
      "ingredients": [
        "1.5 kg de roast de res",
        "4 zanahorias (picadas)",
        "4 papas (en cubos)",
        "2 tazas de caldo de carne",
        "Sal y pimienta"
      ],
      "preparation": "Dora el roast, luego agrega el caldo, las verduras y los condimentos. Cocina en una olla de cocción lenta durante 6-8 horas."
    },
    {
      "name": "Sándwich de Ensalada de Huevo",
      "ingredients": [
        "4 huevos cocidos",
        "2 cucharadas de mayonesa",
        "1 cucharada de mostaza",
        "Sal y pimienta",
        "4 rebanadas de pan"
      ],
      "preparation": "Tritura los huevos y mézclalos con la mayonesa, la mostaza, la sal y la pimienta. Unta en el pan y sirve."
    },
    {
      "name": "Quiche Clásico",
      "ingredients": [
        "1 masa para tarta",
        "4 huevos",
        "1 taza de crema",
        "1 taza de queso",
        "1/2 taza de jamón (opcional)"
      ],
      "preparation": "Precalienta el horno a 190°C (375°F). Bate los huevos con la crema. Agrega el queso y el jamón, luego vierte en la masa para tarta. Hornea durante 30-35 minutos."
    },
    {
      "name": "Pastel de Manzana",
      "ingredients": [
        "4 manzanas (peladas y en rodajas)",
        "1 taza de azúcar",
        "1 cucharada de canela",
        "2 cucharadas de mantequilla",
        "1 masa para tarta"
      ],
      "preparation": "Precalienta el horno a 220°C (425°F). Mezcla las manzanas con el azúcar y la canela. Colócalas en la masa para tarta, agrega la mantequilla por encima y luego cubre con la segunda capa de masa. Hornea durante 45 minutos."
    }
  ],
};