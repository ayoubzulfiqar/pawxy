import 'package:equatable/equatable.dart';
import '../../domain/server_model.dart';

abstract class ServerState extends Equatable {
  const ServerState();

  @override
  List<Object?> get props => [];
}

class ServerInitial extends ServerState {}

class ServerLoading extends ServerState {}

class ServerLoaded extends ServerState {
  final List<ServerModel> allServers;
  final List<ServerModel> filteredServers;
  final ServerModel selectedServer;
  final String searchQuery;
  final String selectedCategory; // 'All', 'Free', 'Pro'

  const ServerLoaded({
    required this.allServers,
    required this.filteredServers,
    required this.selectedServer,
    this.searchQuery = '',
    this.selectedCategory = 'All',
  });

  ServerLoaded copyWith({
    List<ServerModel>? allServers,
    List<ServerModel>? filteredServers,
    ServerModel? selectedServer,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return ServerLoaded(
      allServers: allServers ?? this.allServers,
      filteredServers: filteredServers ?? this.filteredServers,
      selectedServer: selectedServer ?? this.selectedServer,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [
        allServers,
        filteredServers,
        selectedServer,
        searchQuery,
        selectedCategory,
      ];
}

class ServerError extends ServerState {
  final String message;

  const ServerError(this.message);

  @override
  List<Object?> get props => [message];
}
