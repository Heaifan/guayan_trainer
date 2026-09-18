library;

import '../ast/binding_selector.dart';
import '../ast/rule_binding.dart';
import '../facts/fact_snapshot.dart';
import '../facts/semantic_ref.dart';
import '../objects/dynamic_object_resolver.dart';
import 'rule_trace.dart';

class BindingResolutionResult {
  const BindingResolutionResult(this.context, this.traces);
  final BindingContext context;
  final List<RuleTrace> traces;
}

class BindingResolutionException implements Exception {
  final String message;
  BindingResolutionException(this.message);
  @override
  String toString() => 'BindingResolutionException: $message';
}

class BindingContext {
  final Map<String, SemanticRef> _resolvedBindings = {};
  BindingContext([Map<String, SemanticRef>? initialBindings]) {
    if (initialBindings != null) _resolvedBindings.addAll(initialBindings);
  }
  void add(String name, SemanticRef ref) => _resolvedBindings[name] = ref;
  SemanticRef? get(String name) => _resolvedBindings[name];
  Map<String, SemanticRef> get allBindings =>
      Map.unmodifiable(_resolvedBindings);
}

class BindingResolver {
  const BindingResolver();

  BindingResolutionResult resolveWithTrace(
    List<RuleBinding> bindings,
    FactSnapshot snapshot,
  ) {
    final context = BindingContext();
    final traces = <RuleTrace>[];
    for (final binding in bindings) {
      try {
        final ref = _resolveSelector(binding.selector, context, snapshot);
        if (ref == null) throw BindingResolutionException('未解析到对象');
        context.add(binding.name, ref);
        traces.add(RuleTrace(
          kind: RuleTraceKind.binding,
          label: '${binding.name} ${_selectorLabel(binding.selector)}',
          status: RuleTraceStatus.matched,
          resolvedObjects: [ref],
        ));
      } catch (error) {
        traces.add(RuleTrace(
          kind: RuleTraceKind.binding,
          label: '${binding.name} ${_selectorLabel(binding.selector)}',
          status: RuleTraceStatus.error,
          reason: error.toString(),
        ));
      }
    }
    return BindingResolutionResult(context, List.unmodifiable(traces));
  }

  BindingContext resolve(List<RuleBinding> bindings, FactSnapshot snapshot) {
    final context = BindingContext();
    final unresolved = List<RuleBinding>.from(bindings);
    while (unresolved.isNotEmpty) {
      bool progress = false;
      final toRemove = <RuleBinding>[];
      for (final binding in unresolved) {
        try {
          final ref = _resolveSelector(binding.selector, context, snapshot);
          if (ref != null) {
            context.add(binding.name, ref);
            toRemove.add(binding);
            progress = true;
          }
        } on BindingResolutionException catch (_) {}
      }
      if (!progress) {
        throw BindingResolutionException(
          'Failed to resolve bindings: ${unresolved.map((b) => b.name).join(', ')}',
        );
      }
      unresolved.removeWhere((b) => toRemove.contains(b));
    }
    return context;
  }

  SemanticRef? _resolveSelector(
    BindingSelector selector,
    BindingContext context,
    FactSnapshot snapshot,
  ) {
    if (selector is DirectSelector) return _parseSemanticRef(selector.target);
    if (selector is DynamicBindingSelector) {
      return const DynamicObjectResolver().resolveSingle(selector, snapshot);
    }
    if (selector is RelativeSelector) {
      final baseRef = context.get(selector.baseBinding);
      if (baseRef == null) {
        throw BindingResolutionException(
          'Base not found: ${selector.baseBinding}',
        );
      }
      final fact = snapshot.facts
          .where((f) => f.subject == baseRef && f.predicateId == selector.path)
          .firstOrNull;
      if (fact == null) {
        throw BindingResolutionException('Unknown path or no relation found');
      }
      final val = fact.value.value;
      if (val is String) return _parseSemanticRef(val);
      throw BindingResolutionException('Invalid SemanticRef string');
    }
    throw BindingResolutionException('Unsupported selector');
  }

  SemanticRef _parseSemanticRef(String targetStr) {
    final parts = targetStr.split('/');
    if (parts.length != 2 || parts.any((part) => part.isEmpty)) {
      throw BindingResolutionException('非法 SemanticRef: $targetStr');
    }
    return SemanticRef(parts[0], parts[1]);
  }

  String _selectorLabel(BindingSelector selector) => switch (selector) {
        DirectSelector(:final target) => 'DirectSelector($target)',
        RelativeSelector(:final baseBinding, :final path) =>
          'RelativeSelector($baseBinding.$path)',
        DynamicBindingSelector(:final selectorId) => selectorId,
        _ => selector.runtimeType.toString(),
      };
}
