import 'package:mobile_dev_summative/core/repositories/base_repository.dart';
import 'package:mobile_dev_summative/features/projects/domain/repositories/project_repository.dart';
import 'package:mobile_dev_summative/features/projects/models/project.dart';
import 'package:mobile_dev_summative/features/projects/models/project_level.dart';

class ProjectRepositoryImpl extends BaseRepository<Project>
    implements ProjectRepository {
  ProjectRepositoryImpl() : super('projects', Project.fromMap);

  Future<void> _seedIfEmpty() async {
    final existing = await collectionRef.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final now = DateTime.now();
    final sampleProjects = [
      Project(
        id: '',
        createdAt: now,
        updatedAt: now,
        title: 'Build your first Doctype',
        subtitle: 'Frappe Framework basics',
        description:
            'Create your first Doctype in the Frappe framework, the building '
            'block of every ERPNext module. You will define fields, set naming '
            'rules, and save your first record.',
        level: ProjectLevel.beginner,
        objectives: const [
          'Set up a Frappe site and log in to the desk',
          'Create a new Doctype with fields and naming rules',
          'Add list and form views for your Doctype',
          'Save a record and verify it in the database',
        ],
        steps: [
          ProjectStep(
            title: 'Create the Doctype',
            detail:
                'In the Frappe desk, open the Doctype list and create a new '
                'Doctype named "Book". Give it a module and a naming series.',
          ),
          ProjectStep(
            title: 'Add fields',
            detail:
                'Add a Data field for the title and a Link field pointing to '
                'the Author doctype. Mark the title as mandatory.',
          ),
          ProjectStep(
            title: 'Configure views',
            detail:
                'Set the title field as the list-view label and reorder the '
                'form so the most important fields appear first.',
          ),
          ProjectStep(
            title: 'Save and verify',
            detail:
                'Create a sample record, save it, and confirm the document '
                'appears in the list view.',
          ),
        ],
      ),
      Project(
        id: '',
        createdAt: now,
        updatedAt: now,
        title: 'ERPNext Sales Module',
        subtitle: 'Quotations, sales orders, invoices',
        description:
            'Work through the core sales cycle in ERPNext, from quotation to '
            'sales order to invoice, and understand how the documents link '
            'together.',
        level: ProjectLevel.beginner,
        objectives: const [
          'Create a customer and a quotation',
          'Convert the quotation into a sales order',
          'Generate a sales invoice from the order',
          'Review the linked documents and their status',
        ],
        steps: [
          ProjectStep(
            title: 'Create a customer',
            detail:
                'Add a new customer record with contact and address details.',
          ),
          ProjectStep(
            title: 'Raise a quotation',
            detail:
                'Create a quotation for the customer with a few sample items '
                'and quantities.',
          ),
          ProjectStep(
            title: 'Convert to sales order',
            detail:
                'Turn the accepted quotation into a sales order and submit it.',
          ),
          ProjectStep(
            title: 'Generate an invoice',
            detail:
                'Create a sales invoice from the order and confirm the totals '
                'match.',
          ),
        ],
      ),
      Project(
        id: '',
        createdAt: now,
        updatedAt: now,
        title: 'Custom Client Scripts',
        subtitle: 'Automate forms with client-side logic',
        description:
            'Use client scripts to add interactivity to ERPNext forms, '
            'reacting to user input and setting field values automatically.',
        level: ProjectLevel.intermediate,
        objectives: const [
          'Understand the client script event model',
          'Write a script that reacts to a field change',
          'Set a field value automatically based on another field',
          'Test the script on a live form',
        ],
        steps: [
          ProjectStep(
            title: 'Create a client script',
            detail:
                'Add a new Client Script targeting the Sales Order doctype.',
          ),
          ProjectStep(
            title: 'React to a field change',
            detail:
                'Write a handler that runs when the quantity field changes.',
          ),
          ProjectStep(
            title: 'Set a value automatically',
            detail:
                'Calculate and set a discount field based on the quantity.',
          ),
          ProjectStep(
            title: 'Test on a live form',
            detail: 'Open a Sales Order and confirm the script behaves.',
          ),
        ],
      ),
      Project(
        id: '',
        createdAt: now,
        updatedAt: now,
        title: 'Workflow Automation',
        subtitle: 'Approval flows and server scripts',
        description:
            'Design a multi-step approval workflow in ERPNext and back it with '
            'a server script for validation.',
        level: ProjectLevel.intermediate,
        objectives: const [
          'Design an approval workflow with states and transitions',
          'Assign roles to each transition',
          'Add a server script for validation',
          'Test the full approval path',
        ],
        steps: [
          ProjectStep(
            title: 'Define workflow states',
            detail:
                'Create Draft, Pending Approval, and Approved states for a '
                'doctype.',
          ),
          ProjectStep(
            title: 'Add transitions',
            detail:
                'Define who can move a document between each pair of states.',
          ),
          ProjectStep(
            title: 'Add a server script',
            detail:
                'Write a validation that blocks approval when a field is '
                'empty.',
          ),
          ProjectStep(
            title: 'Test the path',
            detail:
                'Walk a document through the full workflow and confirm the '
                'rules hold.',
          ),
        ],
      ),
    ];

    for (final project in sampleProjects) {
      await create(project);
    }
  }

  @override
  Future<List<Project>> getAll() async {
    await _seedIfEmpty();
    return findAll();
  }

  @override
  Future<Project?> getById(String id) {
    return findById(id);
  }
}