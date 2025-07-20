import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb; // Use the web database factory
  } else {
    databaseFactory =
        databaseFactoryFfi; // Use the FFI database factory for other platforms
  }
  runApp(const AIHubApp());
}

class AIHubApp extends StatelessWidget {
  const AIHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Tools Hub',
      showSemanticsDebugger: false,
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16),
        ),
      ),
      home: const ToolsPage(),
    );
  }
}

class Tool {
  final String name;
  final String description;
  final String link;
  final String category;
  final bool isFree;
  final int popularity; // Add popularity field

  Tool(
    this.name,
    this.description,
    this.link,
    this.category, {
    this.isFree = true,
    this.popularity = 0,
  });
}

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  SortOption _selectedSortOption = SortOption.nameAsc;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<String, int> _ratings = {};
  bool _isGridView = false; // Toggle for list/grid view

  void _sortTools(List<Tool> tools) {
    switch (_selectedSortOption) {
      case SortOption.nameAsc:
        tools.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        tools.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.rating:
        tools.sort(
          (a, b) => (_ratings[b.name] ?? 0).compareTo(_ratings[a.name] ?? 0),
        );
        break;
      case SortOption.popularity:
        tools.sort((a, b) => b.popularity.compareTo(a.popularity));
        break;
    }
  }

  // Initialize the database
  Future<Database> _initializeDB() async {
    return openDatabase(
      join(await getDatabasesPath(), 'ratings.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE ratings(name TEXT PRIMARY KEY, rating INTEGER)",
        );
      },
      version: 1,
    );
  }

  // Load ratings from the database
  Future<void> _loadRatings() async {
    final db = await _initializeDB();
    final List<Map<String, dynamic>> maps = await db.query('ratings');

    for (var map in maps) {
      _ratings[map['name']] = map['rating'];
    }
    setState(() {});
  }

  // Save rating to the database
  Future<void> _saveRating(String name, int rating) async {
    final db = await _initializeDB();
    await db.insert('ratings', {
      'name': name,
      'rating': rating,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  final List<Tool> tools = [
    Tool(
      "Penpot",
      "Open-source design tool for creating user interfaces. It allows collaboration and prototyping in a web-based environment. Ideal for designers looking for a free alternative to proprietary software.",
      "https://penpot.app",
      "AI for UI/UX Design & Prototyping",
      popularity: 150,
    ),

    Tool(
      "Figma Starter",
      "Free plan for individual design files, enabling users to create and collaborate on UI designs. It offers a user-friendly interface and real-time collaboration features. Perfect for freelancers and small teams.",
      "https://figma.com",
      "AI for UI/UX Design & Prototyping",
      popularity: 200,
    ),

    Tool(
      "Codeium",
      "AI autocomplete plugin designed for code editors, enhancing coding efficiency. It provides intelligent code suggestions and snippets. A must-have tool for developers looking to speed up their workflow.",
      "https://codeium.com",
      "AI for Code & App Generation",
      popularity: 120,
    ),

    Tool(
      "OpenRouter.ai",
      "Multi-LLM API gateway that simplifies access to various language models. It allows developers to integrate AI capabilities into their applications seamlessly. Ideal for those looking to leverage multiple AI models.",
      "https://openrouter.ai",
      "AI Integration for Mobile Development",
      popularity: 90,
    ),

    Tool(
      "Merlin",
      "AI productivity Chrome extension that enhances browsing experience. It offers features like summarization and task management. Great for users looking to boost their productivity while online.",
      "https://getmerlin.in",
      "Best AI Chrome Extensions",
      popularity: 180,
    ),

    Tool(
      "LazyApply",
      "Automated job application tool that streamlines the job search process. It allows users to apply to multiple jobs with a single click. Perfect for job seekers looking to save time and effort.",
      "https://lazyapply.com",
      "AI for Job Search Automation",
      popularity: 110,
    ),

    Tool(
      "Interview Coder",
      "Platform for practicing coding interviews with real-time feedback. It helps users prepare for technical interviews effectively. Ideal for developers looking to sharpen their coding skills.",
      "https://interviewcoderai.com",
      "AI Tools for Interview Preparation",
      popularity: 130,
    ),

    Tool(
      "Perplexity AI",
      "Conversational search engine that provides answers in a chat-like format. It leverages AI to understand user queries and deliver relevant information. Great for users seeking quick and accurate answers.",
      "https://www.perplexity.ai",
      "Powerful AI Assistants",
      popularity: 160,
    ),

    Tool(
      "Google Gemini",
      "Google's generative AI model designed for various applications. It offers advanced capabilities in natural language processing and understanding. Ideal for developers looking to integrate cutting-edge AI technology.",
      "https://deepmind.google/technologies/gemini",
      "Powerful AI Assistants",
      popularity: 220,
    ),

    Tool(
      "Claude AI",
      "Anthropic's AI assistant focused on safety and usability. It provides conversational capabilities while prioritizing user privacy. Perfect for those looking for a reliable AI companion.",
      "https://claude.ai",
      "Powerful AI Assistants",
      popularity: 210,
    ),

    Tool(
      "DeepSeek AI",
      "Advanced AI model by DeepSeek that excels in understanding complex queries. It offers high-quality responses and insights. Ideal for businesses looking to enhance their AI capabilities.",
      "https://deepseek.com",
      "Powerful AI Assistants",
      popularity: 140,
    ),

    Tool(
      "Grok AI",
      "AI assistant developed by xAI (Elon Musk) for various applications. It aims to provide intelligent responses and assist users in their tasks. Great for those interested in innovative AI solutions.",
      "https://x.ai",
      "Powerful AI Assistants",
      popularity: 160,
    ),

    Tool(
      "You.com AI",
      "Private AI search assistant that prioritizes user privacy. It offers personalized search results and recommendations. Ideal for users looking for a secure search experience.",
      "https://you.com",
      "Powerful AI Assistants",
      popularity: 130,
    ),

    Tool(
      "Pi.ai",
      "Personal AI assistant designed to help users manage tasks and information. It offers a user-friendly interface and smart suggestions. Perfect for individuals seeking a digital assistant.",
      "https://pi.ai",
      "Powerful AI Assistants",
      popularity: 150,
    ),

    Tool(
      "Qwen AI",
      "Alibaba's AI model that provides various AI services. It focuses on enhancing user experience through intelligent interactions. Ideal for businesses looking to leverage AI technology.",
      "https://qwen.alibaba.com",
      "Powerful AI Assistants",
      popularity: 120,
    ),

    Tool(
      "Microsoft Copilot",
      "AI assistant integrated into Microsoft tools for enhanced productivity. It offers smart suggestions and automates repetitive tasks. Great for users of Microsoft Office and other applications.",
      "https://copilot.microsoft.com",
      "Powerful AI Assistants",
      popularity: 230,
    ),

    Tool(
      "Proto.io",
      "Rapid prototyping platform that allows users to create interactive prototypes. It offers a drag-and-drop interface for ease of use. Ideal for designers looking to visualize their ideas quickly.",
      "https://proto.io",
      "AI for UI/UX Design & Prototyping",
      popularity: 140,
    ),

    Tool(
      "Framer AI",
      "Website builder that incorporates AI to streamline the design process. It allows users to create responsive websites with ease. Perfect for designers and developers looking for efficiency.",
      "https://framer.com/ai",
      "AI for UI/UX Design & Prototyping",
      popularity: 130,
    ),

    Tool(
      "Uizard",
      "AI design tool that transforms sketches into digital designs. It simplifies the design process for non-designers. Ideal for teams looking to quickly prototype ideas.",
      "https://uizard.io",
      "AI for UI/UX Design & Prototyping",
      popularity: 110,
    ),

    Tool(
      "Galileo AI",
      "AI design assistant that helps users create stunning visuals. It offers design suggestions based on user input. Great for those looking to enhance their design skills.",
      "https://www.usegalileo.ai",
      "AI for UI/UX Design & Prototyping",
      popularity: 120,
    ),

    Tool(
      "Visily AI",
      "AI-powered wireframing tool that simplifies the design process. It allows users to create wireframes quickly and efficiently. Ideal for UX designers looking to streamline their workflow.",
      "https://www.visily.ai",
      "AI for UI/UX Design & Prototyping",
      popularity: 100,
    ),

    Tool(
      "UX Pilot",
      "UX enhancement tool that provides insights and recommendations. It helps improve user experience through data-driven suggestions. Perfect for UX researchers and designers.",
      "https://uxpilot.ai",
      "AI for UI/UX Design & Prototyping",
      popularity: 90,
    ),

    Tool(
      "Testim",
      "AI-based test automation platform that accelerates testing processes. It offers intelligent test creation and maintenance features. Ideal for QA teams looking to improve efficiency.",
      "https://www.testim.io",
      "AI for App Testing & Quality Assurance",
      popularity: 150,
    ),

    Tool(
      "Applitools",
      "Visual testing tool that leverages AI for accurate results. It helps ensure UI consistency across applications. Great for teams focused on quality assurance.",
      "https://applitools.com",
      "AI for App Testing & Quality Assurance",
      popularity: 160,
    ),

    Tool(
      "Percy",
      "UI testing tool by BrowserStack that automates visual testing. It provides instant feedback on UI changes. Ideal for developers looking to maintain visual quality.",
      "https://percy.io",
      "AI for App Testing & Quality Assurance",
      popularity: 140,
    ),

    Tool(
      "Mabl",
      "Low-code test automation platform that simplifies testing. It allows users to create tests without extensive coding knowledge. Perfect for teams looking to enhance their testing capabilities.",
      "https://www.mabl.com",
      "AI for App Testing & Quality Assurance",
      popularity: 130,
    ),

    Tool(
      "Functionize",
      "Test automation powered by AI that improves testing efficiency. It offers intelligent test creation and execution features. Ideal for QA teams looking to streamline their processes.",
      "https://www.functionize.com",
      "AI for App Testing & Quality Assurance",
      popularity: 120,
    ),

    Tool(
      "Testsigma",
      "Open-source test automation tool that supports various testing types. It allows teams to collaborate on test cases easily. Great for organizations looking for a flexible testing solution.",
      "https://testsigma.com",
      "AI for App Testing & Quality Assurance",
      popularity: 110,
    ),

    Tool(
      "Diffblue Cover",
      "Unit test generation tool that automates the creation of tests. It helps developers ensure code quality and reliability. Ideal for teams looking to enhance their testing practices.",
      "https://www.diffblue.com",
      "AI for App Testing & Quality Assurance",
      popularity: 100,
    ),

    Tool(
      "Yourware",
      "App builder that utilizes AI to simplify development. It allows users to create applications without extensive coding knowledge. Perfect for entrepreneurs and startups looking to launch quickly.",
      "https://yourware.ai",
      "AI for Code & App Generation",
      popularity: 150,
    ),

    Tool(
      "Bolt.new",
      "AI code and app builder that accelerates development processes. It offers a user-friendly interface for creating applications. Ideal for developers looking to save time on coding.",
      "https://bolt.new",
      "AI for Code & App Generation",
      popularity: 140,
    ),

    Tool(
      "Lovable AI",
      "App builder that allows users to create applications using plain English. It simplifies the development process for non-technical users. Great for anyone looking to turn ideas into apps easily.",
      "https://lovable.ai",
      "AI for Code & App Generation",
      popularity: 130,
    ),

    Tool(
      "Databutton AI",
      "Full-stack app generation tool that automates the development process. It allows users to create complex applications quickly. Ideal for developers looking to streamline their workflow.",
      "https://databutton.com",
      "AI for Code & App Generation",
      popularity: 120,
    ),

    Tool(
      "Tempo AI",
      "Build apps from prompts using AI technology. It simplifies the app development process for users. Perfect for those looking to create applications without extensive coding.",
      "https://tempo.build",
      "AI for Code & App Generation",
      popularity: 110,
    ),

    Tool(
      "AWS Kiro",
      "AWS AI assistant that helps users manage cloud resources. It offers intelligent suggestions for optimizing cloud usage. Ideal for businesses leveraging AWS services.",
      "https://aws.amazon.com/kiro",
      "AI for Code & App Generation",
      popularity: 100,
    ),

    Tool(
      "Replit Agent",
      "AI pair programmer that assists developers in coding tasks. It provides suggestions and helps debug code. Great for developers looking for an interactive coding experience.",
      "https://replit.com/ghostwriter",
      "AI for Code & App Generation",
      popularity: 90,
    ),

    Tool(
      "Dropbase AI",
      "Tool that converts spreadsheets to databases using AI. It simplifies data management for users. Ideal for businesses looking to streamline their data processes.",
      "https://dropbase.io",
      "AI for Code & App Generation",
      popularity: 80,
    ),

    Tool(
      "OpenAI GPT API",
      "Access to GPT models for various applications. It allows developers to integrate advanced language processing capabilities. Perfect for those looking to leverage AI in their projects.",
      "https://platform.openai.com",
      "AI Integration for Mobile Development",
      popularity: 250,
    ),

    Tool(
      "Gemini API",
      "Access to Google Gemini for advanced AI capabilities. It provides developers with tools to enhance their applications. Ideal for those looking to utilize Google's AI technology.",
      "https://makersuite.google.com",
      "AI Integration for Mobile Development",
      popularity: 240,
    ),

    Tool(
      "Claude API",
      "Anthropic's Claude API for integrating AI into applications. It offers powerful language processing features. Great for developers looking to enhance user interactions.",
      "https://www.anthropic.com",
      "AI Integration for Mobile Development",
      popularity: 230,
    ),

    Tool(
      "Mistral AI",
      "Language model API that provides advanced AI capabilities. It allows developers to integrate sophisticated language processing into their applications. Ideal for those looking to enhance their AI offerings.",
      "https://mistral.ai",
      "AI Integration for Mobile Development",
      popularity: 220,
    ),

    Tool(
      "Cohere API",
      "LLM-as-a-service that provides access to large language models. It allows developers to integrate AI capabilities into their applications easily. Perfect for businesses looking to leverage AI technology.",
      "https://cohere.com",
      "AI Integration for Mobile Development",
      popularity: 210,
    ),

    Tool(
      "Meta LLaMA 3",
      "Third-party access to Meta's LLaMA model for AI applications. It offers advanced capabilities in natural language processing. Ideal for developers looking to utilize cutting-edge AI technology.",
      "https://huggingface.co/meta-llama",
      "AI Integration for Mobile Development",
      popularity: 200,
    ),

    Tool(
      "HuggingFace Inference API",
      "Deploy and run models using Hugging Face's infrastructure. It simplifies the process of integrating AI models into applications. Great for developers looking to leverage pre-trained models.",
      "https://huggingface.co/inference-api",
      "AI Integration for Mobile Development",
      popularity: 190,
    ),

    Tool(
      "HyperWrite AI",
      "Writing assistant that helps users improve their writing skills. It offers suggestions and corrections in real-time. Ideal for anyone looking to enhance their writing quality.",
      "https://hyperwriteai.com",
      "Best AI Chrome Extensions",
      popularity: 160,
    ),

    Tool(
      "HIX AI",
      "Writing and productivity suite that enhances user efficiency. It offers tools for writing, organizing, and managing tasks. Perfect for professionals looking to boost their productivity.",
      "https://hix.ai",
      "Best AI Chrome Extensions",
      popularity: 150,
    ),

    Tool(
      "Compose AI",
      "Auto-complete tool for writing that speeds up the writing process. It provides intelligent suggestions based on user input. Ideal for writers looking to save time and improve flow.",
      "https://www.compose.ai",
      "Best AI Chrome Extensions",
      popularity: 140,
    ),

    Tool(
      "NoteGPT",
      "Tool for summarizing and taking notes efficiently. It helps users capture key points from texts and lectures. Great for students and professionals looking to enhance their note-taking.",
      "https://notegpt.io",
      "Best AI Chrome Extensions",
      popularity: 130,
    ),

    Tool(
      "Otter AI",
      "Meeting transcription tool that captures spoken content accurately. It provides searchable transcripts for easy reference. Ideal for professionals looking to keep track of meetings.",
      "https://otter.ai",
      "Best AI Chrome Extensions",
      popularity: 120,
    ),

    Tool(
      "Asper AI",
      "Productivity AI extension that helps users manage tasks and schedules. It offers smart reminders and organization features. Perfect for busy professionals looking to stay on top of their work.",
      "https://asper.ai",
      "Best AI Chrome Extensions",
      popularity: 110,
    ),

    Tool(
      "LoopCV",
      "Automated job hunting tool that simplifies the job search process. It helps users find and apply for jobs efficiently. Ideal for job seekers looking to streamline their applications.",
      "https://loopcv.pro",
      "AI for Job Search Automation",
      popularity: 130,
    ),

    Tool(
      "Bulk Apply",
      "Tool for mass job applications that saves time for job seekers. It allows users to apply to multiple positions with a single click. Great for those looking to maximize their job search efforts.",
      "https://bulkapply.ai",
      "AI for Job Search Automation",
      popularity: 120,
    ),

    Tool(
      "JobCopilot",
      "AI job copilot that assists users in their job search. It provides personalized job recommendations and application tips. Perfect for anyone looking to enhance their job search strategy.",
      "https://jobcopilot.ai",
      "AI for Job Search Automation",
      popularity: 110,
    ),

    Tool(
      "AIApply",
      "One-click job application tool that simplifies the application process. It allows users to apply to jobs quickly and easily. Ideal for job seekers looking to save time.",
      "https://aiapply.io",
      "AI for Job Search Automation",
      popularity: 100,
    ),

    Tool(
      "Interview Coder (Alt)",
      "Alternative platform for Interview Coder focused on coding practice. It offers a variety of coding challenges and feedback. Great for developers preparing for technical interviews.",
      "https://interviewcoder.co",
      "AI Tools for Interview Preparation",
      popularity: 90,
    ),

    Tool(
      "JobBridge",
      "Interview prep AI that helps users prepare for job interviews. It offers practice questions and feedback on responses. Ideal for candidates looking to improve their interview skills.",
      "https://jobbridge.app",
      "AI Tools for Interview Preparation",
      popularity: 80,
    ),

    Tool(
      "Parakeet AI",
      "Tool for generating interview Q&A based on job descriptions. It helps users prepare for specific roles effectively. Perfect for job seekers looking to tailor their interview preparation.",
      "https://parakeet.ai",
      "AI Tools for Interview Preparation",
      popularity: 70,
    ),

    Tool(
      "Yoodli",
      "AI-powered communication coach that helps users improve their speaking skills. It offers feedback on clarity and delivery. Ideal for anyone looking to enhance their communication abilities.",
      "https://yoodli.ai",
      "AI Tools for Interview Preparation",
      popularity: 60,
    ),

    Tool(
      "Google Interview Warmup",
      "Platform for practicing interviews with AI-generated questions. It helps users prepare for various interview scenarios. Great for candidates looking to build confidence before interviews.",
      "https://grow.google/interview-warmup",
      "AI Tools for Interview Preparation",
      popularity: 50,
    ),

    Tool(
      "Pramp",
      "Mock interview platform that connects users with peers for practice. It offers real-time feedback and a variety of interview questions. Ideal for candidates looking to gain experience in a supportive environment.",
      "https://pramp.com",
      "AI Tools for Interview Preparation",
      popularity: 40,
    ),

    Tool(
      "InterviewAI",
      "AI interview prep tool that provides personalized practice sessions. It helps users improve their responses and interview techniques. Perfect for job seekers aiming to enhance their interview performance.",
      "https://interviewai.io",
      "AI Tools for Interview Preparation",
      popularity: 30,
    ),

    Tool(
      "InterviewBuddy",
      "Live interview practice platform that connects users with interviewers. It offers real-time feedback and coaching. Great for candidates looking to refine their interview skills in a realistic setting.",
      "https://interviewbuddy.in",
      "AI Tools for Interview Preparation",
      popularity: 20,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadRatings(); // Load ratings on init
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildToolCard(Tool tool) {
    return ToolCard(
      tool: tool,
      onRatingUpdate: (rating) {
        setState(() {
          _ratings[tool.name] = rating.toInt();
          _saveRating(tool.name, rating.toInt());
        });
      },
      initialRating: _ratings[tool.name]?.toDouble() ?? 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = tools
        .where(
          (tool) =>
              tool.name.toLowerCase().contains(_searchQuery) ||
              tool.description.toLowerCase().contains(_searchQuery),
        )
        .toList();

    _sortTools(filtered); // Sort the filtered tools

    final grouped = <String, List<Tool>>{};
    for (var tool in filtered) {
      grouped.putIfAbsent(tool.category, () => []).add(tool);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 900;
        final crossAxisCount = isMobile
            ? 1
            : isTablet
            ? 2
            : 3;

        return Scaffold(
          appBar: AppBar(
            title: const Text("🧠 Free AI Tools Hub"),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          /// 🔽 Sort Dropdown

                          /// 🧠 Header Description
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Explore a variety of AI tools to enhance your productivity and creativity.',
                                    style: Theme.of(context).textTheme.titleLarge,
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                DropdownButton<SortOption>(
                                  value: _selectedSortOption,
                                  onChanged: (SortOption? newValue) {
                                    setState(() {
                                      _selectedSortOption = newValue!;
                                    });
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                      value: SortOption.nameAsc,
                                      child: Text("Sort by Name (A-Z)"),
                                    ),
                                    DropdownMenuItem(
                                      value: SortOption.nameDesc,
                                      child: Text("Sort by Name (Z-A)"),
                                    ),
                                    DropdownMenuItem(
                                      value: SortOption.rating,
                                      child: Text("Sort by Rating"),
                                    ),
                                    DropdownMenuItem(
                                      value: SortOption.popularity,
                                      child: Text("Sort by Popularity"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// 🔍 Search Box
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: '🔍 Search tools...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// 🗃️ Tool Cards
                          _isGridView
                              ? GridView.builder(
                                  itemCount: grouped.values
                                      .expand((x) => x)
                                      .length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: isMobile ? 1.05 : 0.9,
                                      ),
                                  itemBuilder: (context, index) {
                                    final tool = grouped.values
                                        .expand((x) => x)
                                        .elementAt(index);
                                    return _buildToolCard(tool);
                                  },
                                )
                              : Column(
                                  children: grouped.entries.map((entry) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.key,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          children: entry.value
                                              .map(
                                                (tool) => ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxWidth: isMobile
                                                        ? double.infinity
                                                        : (constraints.maxWidth /
                                                                  crossAxisCount) -
                                                              32,
                                                  ),
                                                  child: _buildToolCard(tool),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                        const SizedBox(height: 24),
                                      ],
                                    );
                                  }).toList(),
                                ),

                          const Spacer(),

                          /// 📎 Sticky Footer at Bottom
                          Footer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Column(
        children: [
          Text(
            '© 2023 Your Company Name. All rights reserved.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  // Add your privacy policy link here
                },
                child: Text('Privacy Policy'),
              ),
              TextButton(
                onPressed: () {
                  // Add your terms of service link here
                },
                child: Text('Terms of Service'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.facebook),
                onPressed: () {
                  // Add your Facebook link here
                },
              ),
              IconButton(
                icon: Icon(Icons.transfer_within_a_station),
                onPressed: () {
                  // Add your Twitter link here
                },
              ),
              IconButton(
                icon: Icon(Icons.dataset_linked_outlined),
                onPressed: () {
                  // Add your LinkedIn link here
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ToolCard extends StatefulWidget {
  final Tool tool;
  final Function(int) onRatingUpdate;
  final double initialRating;

  const ToolCard({
    super.key,
    required this.tool,
    required this.onRatingUpdate,
    required this.initialRating,
  });

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final tool = widget.tool;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: _isHovering ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovering ? Colors.blueAccent : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            if (_isHovering)
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Link
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SelectableText(
                    '${tool.name}${tool.isFree ? " 🔓" : ""}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Open tool in browser',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32),
                      onTap: () async {
                        final url = Uri.parse(tool.link);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.open_in_new,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            SelectableText(
              tool.description,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 18),

            // Rating
            Row(
              children: [
                const SelectableText(
                  'Your Rating:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),
                RatingBar.builder(
                  initialRating: widget.initialRating,
                  minRating: 1,
                  allowHalfRating: true,
                  itemSize: 24,
                  unratedColor: Colors.grey.shade300,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star_rounded, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    widget.onRatingUpdate(rating.toInt());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum SortOption { nameAsc, nameDesc, rating, popularity }
